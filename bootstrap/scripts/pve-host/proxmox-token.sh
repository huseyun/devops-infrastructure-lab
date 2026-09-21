# usage: proxmox-token.sh <control-node-vmid>
set -euo pipefail

VMID="${1:?kullanim: proxmox-token.sh <vmid>}"
export TOKEN_ID="controlnode"
USER_ID="root@pam"
SECRET_FILE="/root/homelab/.env.controlnode"

pct exec "$VMID" -- test -d /root/homelab \
  || { echo "HATA: /root/homelab yok - once run.ps1"; exit 1; }

if pct exec "$VMID" -- test -s "$SECRET_FILE"; then
  echo "Token dosyasi mevcut - dokunulmadi."; exit 0
fi

if pveum user token list "$USER_ID" --output-format json \
   | perl -MJSON::PP -0777 -ne 'exit !(grep { $_->{tokenid} eq $ENV{TOKEN_ID} } @{decode_json($_)})'; then
  pveum user token remove "$USER_ID" "$TOKEN_ID"
fi

pveum user token add "$USER_ID" "$TOKEN_ID" --privsep 0 --output-format json \
  | perl -MJSON::PP -0777 -ne '$d = decode_json($_); print "PROXMOX_VE_API_TOKEN=", $d->{"full-tokenid"}, "=", $d->{value}, "\n"' \
  | pct exec "$VMID" -- sh -c "umask 077; cat > '$SECRET_FILE.tmp' && [ -s '$SECRET_FILE.tmp' ] && mv '$SECRET_FILE.tmp' '$SECRET_FILE'"

echo "Token uretildi, control node'a yazildi."