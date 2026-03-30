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

# vstupy
echo ""
read -p "Zadej domenu (napr. app.mojedomena.cz): " DOMAIN
read -p "Zadej email (pro HTTPS): " EMAIL

echo ""
echo "Domena: $DOMAIN"
echo "Email:  $EMAIL"
echo ""

# slozka
mkdir -p dbbrix
cd dbbrix

# .env
echo "Vytvarim .env"
cat > .env <<EOF
DOMAIN=$DOMAIN
EMAIL=$EMAIL
EOF

# nginx.conf (🔥 KLÍČOVÉ)
echo "Generuji nginx.conf"
cat > nginx.conf <<'EOF'
server {
    listen 80;

    root /var/www/html/public;
    index index.php index.html;

    location / {
        try_files $uri /index.php?$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass backend:9000;

        fastcgi_param SCRIPT_FILENAME /var/www/html/public$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT /var/www/html/public;
    }
}
EOF

# docker-compose.yml
echo "Stahuji docker-compose.yml"
curl -sSL https://raw.githubusercontent.com/MiroslavVasicek-git/DBBrix-installer/main/docker-compose.yml -o docker-compose.yml

# letsencrypt slozka
mkdir -p letsencrypt
touch letsencrypt/acme.json
chmod 600 letsencrypt/acme.json

# start
echo "Spoustim aplikaci..."
docker compose up -d

echo ""
echo "================================="
echo "Hotovo!"
echo "================================="
echo "Otevri: https://$DOMAIN"
