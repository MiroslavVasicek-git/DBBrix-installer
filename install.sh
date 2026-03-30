#!/bin/bash

echo "🚀 DBBrix instalace"

# kontrola dockeru
if ! command -v docker &> /dev/null
then
    echo "📦 Instaluji Docker..."
    curl -fsSL https://get.docker.com | sh
fi

if ! command -v docker compose &> /dev/null
then
    echo "📦 Instaluji Docker Compose..."
    apt-get install -y docker-compose-plugin
fi

# dotazy na uživatele
read -p "🌐 Zadej doménu: " DOMAIN
read -p "📧 Zadej email (pro HTTPS): " EMAIL

# export pro compose
export DOMAIN=$DOMAIN
export EMAIL=$EMAIL

# stažení compose
echo "📥 Stahuji docker-compose.yml"
curl -O https://raw.githubusercontent.com/MiroslavVasicek-git//DBBrix-installer//main/docker-compose.yml

# spuštění
echo "🚀 Spouštím aplikaci..."
docker compose up -d

echo "✅ Hotovo!"
echo "👉 Otevři: https://$DOMAIN"
