#!/bin/sh

echo "🔥 [CUSTOM-INIT] Ozel baslangic scripti calisiyor..."

# Klasörü oluştur (Garanti olsun)
mkdir -p /etc/dnsmasq.d

# Dosya yolunu değişkene atayalım
CONF_FILE="/etc/dnsmasq.d/99-tailscale.conf"

# --- 1. WILDCARD DNS AYARI ---
# Tüm alt domainleri (örn: *.famanaspc...) ve ana domaini hedef IP'ye yönlendir.
echo "address=/.${LOCAL_DOMAIN}/${TARGET_IP}" > "$CONF_FILE"

# --- 2. MAGICDNS AYARI ---
# .ts.net ile biten diğer Tailscale cihaz sorgularını Tailscale DNS'ine (100.100.100.100) sor.
echo "server=/ts.net/100.100.100.100" >> "$CONF_FILE"

# --- 3. REVERSE DNS AYARI ---
# 100.x.x.x IP'lerinin kime ait olduğunu öğrenmek için Tailscale'e sor.
# (Pi-hole loglarında IP yerine 'iphone', 'macbook' yazar)
echo "rev-server=100.64.0.0/10,100.100.100.100" >> "$CONF_FILE"
echo "rev-server=fd7a:115c:a1e0::/48,100.100.100.100" >> "$CONF_FILE"

# Kontrol
if [ -f "$CONF_FILE" ]; then
    echo "✅ [CUSTOM-INIT] Tailscale ayarlari eklendi:"
    cat "$CONF_FILE"
else
    echo "❌ [CUSTOM-INIT] Dosya olusturulamadi!"
fi

echo "🚀 [CUSTOM-INIT] Gorev tamamlandi, Pi-hole (FTL) baslatiliyor..."

# GÖREV DEVRİ
exec pihole-FTL