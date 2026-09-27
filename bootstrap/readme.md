# bootstrap/ — Control node'u sıfırdan kurmak

Bu klasör **laptop'tan** çalışır ve yalnızca bir şey yaratır: **control node** (Debian LXC). Control node, hattın yönetim katmanıdır. `terraform/` ve `ansible/` oradan koşar.

| Katman | Ne yapar | Araç |
|---|---|---|
| Katman 1 | LXC'yi var eder | `tofu` (bu klasördeki `.tf`'ler, **local state**) |
| Katman 2 | İçini kurar (mise, tofu, ansible, SSH kimliği) | `scripts/control-node/bootstrap.sh` |
| Token | Control node'a kendi Proxmox token'ını verir | `scripts/pve-host/proxmox-token.sh` |

> ⚠️ **Operasyon sınırı:** `bootstrap/` üzerinde `tofu apply`/`destroy` **yalnızca laptop'tan** yapılır. Control node'da (repo orada da clone'lu) koşarsan, tofu mevcut control node'u tanımaz ve ikincisini yaratmaya kalkar.
> `bootstrap/terraform.tfstate`'in bir yedeğini **Git dışında** sakla. Laptop değişirse elle taşınır.

---

## Klasör haritası

```
bootstrap/
├── *.tf                       kök modül (burada kalmak zorunda)
└── scripts/
    ├── laptop/                laptop'ta koşar
    │   ├── run.ps1            Katman 2 tetiği
    │   ├── token.ps1          token tetiği
    │   └── connect.ps1        operatör olarak giriş
    ├── pve-host/              Proxmox host'unda koşar
    │   └── proxmox-token.sh
    └── control-node/          control node içinde koşar
        └── bootstrap.sh
```

---

## Önkoşullar (bir kerelik)

**Laptop:**

- PowerShell, OpenSSH istemcisi (Windows'ta yerleşik), Git, mise.
- `tofu` sürümü repo kökündeki `mise.toml`'dan gelir.
- Operatör SSH anahtarı:

  ```powershell
  ssh-keygen -t ed25519 -f $HOME\.ssh\id_ed25519_homelab -C "operator@laptop"
  ```

- Proxmox host'una root SSH erişimi (yalnızca `token.ps1` için).

**Proxmox host'u:**

- Debian 13 template'i (K12, bir kerelik):

  ```bash
  pveam update
  pveam available --section system | grep debian-13
  pveam download local debian-13-standard_<SURUM>_amd64.tar.zst
  ```

- Laptop'ın API token'ı (root of trust):

  ```bash
  pveum user token add root@pam <TOKEN_ADI> --privsep 0
  ```

  Çıkan değer yalnızca bir kez gösterilir. `env.example.ps1`'i `env.ps1` olarak kopyalayıp içine yaz (`env.ps1` gitignored).

**Değişken config:** `variables.tf`'teki default'suz değişkenleri (ör. Proxmox node adı) `terraform.tfvars`'a yaz (gitignored).

---

## Kurulum

Repo kökünden, sırayla:

```powershell
# 1) Secret'ı oturuma yükle
. .\env.ps1

# 2) Katman 1: LXC'yi yarat
tofu -chdir=bootstrap init
tofu -chdir=bootstrap fmt -check
tofu -chdir=bootstrap validate
tofu -chdir=bootstrap plan
tofu -chdir=bootstrap apply

# 3) Katman 2: içini kur
.\bootstrap\scripts\laptop\run.ps1

# 4) Control node'a kendi Proxmox token'ını ver
.\bootstrap\scripts\laptop\token.ps1 -PveHost root@<PVE_IP>
```

**Beklenen:**

- `run.ps1` çıktısı `Katman2 tamam: ...` ile biter. Hemen önünde `OpenTofu v...`, `ansible [core ...]` ve bir SSH parmak izi görünür.
- `token.ps1` çıktısı `Token uretildi, control node'a yazildi.` olur.

---

## Sağlık kontrolü

### İdempotentlik (laptop)

```powershell
.\bootstrap\scripts\laptop\run.ps1
.\bootstrap\scripts\laptop\token.ps1 -PveHost root@<PVE_IP>
```

- `run.ps1`: yeni kurulum yapmadan biter. **Parmak izi bir öncekiyle aynı** olmalı.
- `token.ps1`: `Token dosyasi mevcut - dokunulmadi.` yazmalı.

### Control node içi

Önce giriş yap:

```powershell
.\bootstrap\scripts\laptop\connect.ps1
```

Sonra control node'da:

```bash
echo "$MISE_ENV"                                  # controlnode
cd ~/homelab
mise exec -- tofu version                         # pinli OpenTofu
mise exec -- ansible --version                    # pinli ansible
ssh-keygen -lf ~/.ssh/id_ed25519.pub              # ... control-plane@node-control
ls -l .env.controlnode                            # -rw------- (600)

# Token Proxmox API'sinde gerçekten çalışıyor mu?
mise exec -- sh -c \
  'curl -sk -H "Authorization: PVEAPIToken=$PROXMOX_VE_API_TOKEN" https://<PVE_IP>:8006/api2/json/version'
```

Son komut sürüm JSON'u dönmeli. `401` = token ya da yükleme bozuk.

---

## Değişiklik akışı

1. Commit + push.
2. Control node'da: `git -C ~/homelab pull`
3. Laptop'tan: `.\bootstrap\scripts\laptop\run.ps1`

> `bootstrap.sh` laptop'tan scp ile gider, config'ler (mise dosyaları) GitHub'dan gelir. Push'u atlarsan ikisi kayabilir.

---

## Sık sorunlar

| Belirti | Sebep | Çözüm |
|---|---|---|
| `ssh` parola istiyor | Varsayılan olmayan anahtar adı, `-i` verilmedi | `connect.ps1` kullan |
| `REMOTE HOST IDENTIFICATION HAS CHANGED` | Control node yeniden yaratıldı (yeni host key) | `ssh-keygen -R <IP>` |
| `$'\r': command not found` | `.sh` CRLF ile checkout edildi | `.gitattributes` (`*.sh text eol=lf`) yerinde mi bak, dosyayı yeniden checkout et |
| `ssh <ip> "tofu version"` → `command not found` | Etkileşimsiz shell'de mise aktivasyonu yok | `mise exec -- tofu version` kullan |
| Token kayboldu / bozuldu | Değer geri okunamaz | `.env.controlnode`'u sil, `token.ps1`'i yeniden koş (rotasyon) |
| `Control node IP okunamadi` | State'te IP yok ya da DHCP gecikti | `tofu -chdir=bootstrap refresh`, sonra tekrar dene |

---

## Yıkıp yeniden kurmak

```powershell
tofu -chdir=bootstrap destroy
```

Yeniden kurulumda **Kurulum** bölümünü baştan uygula. Dikkat:

- Control node **yeni bir SSH kimliği** ile doğar (farklı parmak izi). Eski kimliği tanıyan guest'lere erişim kopar; guest'lerin anahtarı yeniden dağıtılmalı.
- `terraform/`'un state'i şu an control node üzerinde local durur. Control node'u yıkmadan önce bu state'in yedeği alınmalı (MinIO'ya taşınana kadar geçerli).