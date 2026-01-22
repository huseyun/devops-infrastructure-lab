#!/bin/bash

echo "📦 [HOOK] ffmpeg, exiftool ve procps paketleri kontrol ediliyor..."

# Paketler kurulu değilse kur
if ! command -v ffmpeg &> /dev/null; then
    apt-get update && apt-get install -y \
        ffmpeg \
        exiftool \
        procps \
    && rm -rf /var/lib/apt/lists/*
    echo "✅ [HOOK] Kurulum tamamlandi."
else
    echo "⏩ [HOOK] Paketler zaten var, devam ediliyor."
fi