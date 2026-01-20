#!/bin/bash
# Dosya: scripts/pihole-init.sh

echo "--- Custom DNS Ayarları Başlatılıyor ---"

# 1. WILDCARD VE ANA MAKİNE ÇÖZÜMÜ
# address=/.domain.com/1.2.3.4
# Başındaki nokta (.) sayesinde hem 'nextcloud.domain.com'u
# HEM DE 'domain.com'un kendisini (ana makineyi) kapsar!
echo "address=/.${LOCAL_DOMAIN}/${TARGET_IP}" > /etc/dnsmasq.d/99-tailscale-wildcard.conf

# 2. MAGICDNS'İ GERİ GETİRME (Diğer cihazlar için)
# ts.net ile biten diğer sorguları Tailscale'in iç DNS'ine sorar.
echo "server=/ts.net/100.100.100.100" >> /etc/dnsmasq.d/99-tailscale-wildcard.conf

# 3. REVERSE DNS (Opsiyonel ama önerilir)
# Pi-hole loglarında "100.x.y.z" yerine cihaz isimlerini (iphone, laptop) görmek için.
echo "rev-server=100.64.0.0/10,100.100.100.100" >> /etc/dnsmasq.d/99-tailscale-wildcard.conf

echo "--- Ayarlar tamamlandı: *.${LOCAL_DOMAIN} -> ${TARGET_IP} ---"