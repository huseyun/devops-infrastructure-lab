#!/bin/bash
set -e

echo "🛠️ Ekstra paketler kontrol ediliyor..."

# Paket listesini güncelle ve sadece eksikse yükle (Hız için)
# DEBIAN_FRONTEND=noninteractive: Kurulum sırasında soru sormasını engeller
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ffmpeg \
    exiftool \
    imagemagick \
    procps \
    --no-install-recommends

# Gereksiz dosyaları temizle
rm -rf /var/lib/apt/lists/*

echo "✅ Paket kurulumu tamamlandı. Nextcloud başlatılıyor..."

exec /entrypoint.sh "$@"