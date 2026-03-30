#!/bin/bash
set -e

echo "DBBrix instalace"

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

# vstupy
echo ""
read -p "Zadej domenu (napr. app.mojedomena.cz): " DOMAIN
read -p "Zadej email (pro HTTPS): " EMAIL

export DOMAIN=$DOMAIN
export EMAIL=$EMAIL

# slozka
mkdir -p dbbrix
cd dbbrix

# download
echo "Stahuji docker-compose.yml"
curl -sSL https://raw.githubusercontent.com/MiroslavVasicek-git/DBBrix-installer/main/docker-compose.yml -o docker-compose.yml

# cert slozka
mkdir -p letsencrypt

# start
echo "Spoustim aplikaci..."
docker compose up -d

echo ""
echo "Hotovo!"
echo "Otevri: https://$DOMAIN"
