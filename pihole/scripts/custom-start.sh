#!/bin/sh

echo "🔥 [CUSTOM-INIT] Ozel baslangic scripti calisiyor..."

mkdir -p /etc/dnsmasq.d
CONF_FILE="/etc/dnsmasq.d/99-tailscale.conf"

echo "address=/.${LOCAL_DOMAIN}/${TARGET_IP}" > "$CONF_FILE"
echo "server=/ts.net/100.100.100.100" >> "$CONF_FILE"
echo "rev-server=100.64.0.0/10,100.100.100.100" >> "$CONF_FILE"
echo "rev-server=fd7a:115c:a1e0::/48,100.100.100.100" >> "$CONF_FILE"

if [ -f "$CONF_FILE" ]; then
    echo "[CUSTOM-INIT] Dosya olusturuldu."
else
    echo "[CUSTOM-INIT] Dosya olusturulamadi!"
fi

echo "[CUSTOM-INIT] Gorev tamamlandi, Orjinal Baslangic (/init) tetikleniyor..."

start.sh
