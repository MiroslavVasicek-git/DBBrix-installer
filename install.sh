#!/bin/bash
set -e

echo "🚀 DBBrix instalace"

# --- kontrola Dockeru ---
if ! command -v docker &> /dev/null
then
    echo "📦 Instaluji Docker..."
    curl -fsSL https://get.docker.com | sh
fi

# --- kontrola docker compose ---
if ! docker compose version &> /dev/null
then
    echo "❌ Docker Compose není dostupný"
    exit 1
fi

# --- vstupy od uživatele ---
echo ""
read -p "🌐 Zadej doménu (např. app.mojedomena.cz): " DOMAIN
read -p "📧 Zadej email (pro HTTPS certifikát): " EMAIL

export DOMAIN=$DOMAIN
export EMAIL=$EMAIL

# --- pracovní složka ---
echo ""
echo "📁 Vytvářím složku dbbrix..."
mkdir -p dbbrix
cd dbbrix

# --- stažení docker-compose ---
echo "📥 Stahuji docker-compose.yml"
curl -sSL https://raw.githubusercontent.com/MiroslavVasicek-git/DBBrix-installer/main/docker-compose.yml -o docker-compose.yml

# --- vytvoření složky pro certifikáty ---
mkdir -p letsencrypt

# --- spuštění ---
echo ""
echo "🚀 Spouštím aplikaci..."
docker compose up -d

echo ""
echo "✅ Instalace dokončena!"
echo "👉 Otevři: https://$DOMAIN"
