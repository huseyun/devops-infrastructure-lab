#!/bin/bash

echo "🔥 Dinamik DNS Ayari Yapiliyor..."

# Klasör kontrolü (Pi-hole v6 yapısına uygun)
mkdir -p /etc/dnsmasq.d

# Config dosyasını yaz
echo "address=/.${LOCAL_DOMAIN}/${TARGET_IP}" > /etc/dnsmasq.d/99-wildcard.conf

echo "✅ Ayar Yazildi: address=/.${LOCAL_DOMAIN}/${TARGET_IP}"