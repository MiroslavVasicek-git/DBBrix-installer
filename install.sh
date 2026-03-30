#!/bin/bash
set -e

echo "================================="
echo "   DBBrix instalace"
echo "================================="

# kontrola Dockeru
if ! command -v docker &> /dev/null
then
    echo "Instaluji Docker..."
    curl -fsSL https://get.docker.com | sh
fi

# kontrola docker compose
if ! docker compose version &> /dev/null
then
    echo "Docker Compose není dostupný"
    exit 1
fi

echo ""
read -p "Zadej domenu (napr. app.mojedomena.cz): " DOMAIN
read -p "Zadej email (pro HTTPS): " EMAIL

echo ""
echo "Domena: $DOMAIN"
echo "Email:  $EMAIL"
echo ""

# slozka
mkdir -p ~/dbbrix
cd ~/dbbrix

# vytvoření .env
echo "Vytvarim .env..."
cat <<EOF > .env
DOMAIN=$DOMAIN
EMAIL=$EMAIL
EOF

# letsencrypt
mkdir -p letsencrypt
touch letsencrypt/acme.json
chmod 600 letsencrypt/acme.json

# docker-compose download
echo "Stahuji docker-compose.yml..."
curl -sSL https://raw.githubusercontent.com/MiroslavVasicek-git/DBBrix-installer/main/docker-compose.yml -o docker-compose.yml

# stop stare
docker compose down 2>/dev/null || true

# start
echo "Spoustim aplikaci..."
docker compose up -d

echo ""
echo "================================="
echo "Hotovo!"
echo "================================="
echo "Otevri: https://$DOMAIN"
