#!/bin/bash
set -e

echo "================================="
echo "   DBBrix instalace"
echo "================================="

# -----------------------------
# VSTUPY (funguje i pro curl | bash)
# -----------------------------
if [ -z "$DOMAIN" ]; then
  read -p "Zadej domenu (napr. app.mojedomena.cz): " DOMAIN
fi

if [ -z "$EMAIL" ]; then
  read -p "Zadej email (pro HTTPS): " EMAIL
fi

export DOMAIN=$DOMAIN
export EMAIL=$EMAIL

echo ""
echo "Domena: $DOMAIN"
echo "Email:  $EMAIL"
echo ""

# -----------------------------
# DOCKER INSTALL
# -----------------------------
if ! command -v docker &> /dev/null
then
    echo "Instaluji Docker..."
    curl -fsSL https://get.docker.com | sh
fi

# docker compose check
if ! docker compose version &> /dev/null
then
    echo "Docker Compose plugin chybi -> instaluji"
    apt-get update -y
    apt-get install -y docker-compose-plugin
fi


# -----------------------------
# SLOZKA
# -----------------------------
mkdir -p ~/dbbrix
cd ~/dbbrix

# -----------------------------
# DOWNLOAD COMPOSE
# -----------------------------
echo "Stahuji docker-compose.yml..."
curl -sSL https://raw.githubusercontent.com/MiroslavVasicek-git/DBBrix-installer/main/docker-compose.yml -o docker-compose.yml

# -----------------------------
# NGINX CONFIG (AUTO GENERACE)
# -----------------------------
echo "Generuji nginx.conf..."

cat <<EOF > nginx.conf
server {
    listen 80;

    location / {
        proxy_pass http://backend:9000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# -----------------------------
# CERT STORAGE
# -----------------------------
mkdir -p letsencrypt

# -----------------------------
# START
# -----------------------------
echo "Spoustim aplikaci..."
docker compose up -d

echo ""
echo "================================="
echo "Hotovo!"
echo "================================="
echo "Otevri: https://$DOMAIN"
echo ""
