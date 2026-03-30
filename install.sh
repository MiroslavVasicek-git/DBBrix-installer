#!/bin/bash
set -e

echo "================================="
echo "   DBBrix instalace"
echo "================================="

# kontrola Dockeru
if ! command -v docker &> /dev/null; then
    echo "Instaluji Docker..."
    curl -fsSL https://get.docker.com | sh
fi

# kontrola docker compose
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose není dostupný"
    exit 1
fi

# kontrola dig
if ! command -v dig &> /dev/null; then
    echo "Instaluji dnsutils (dig)..."
    apt update && apt install -y dnsutils
fi

echo ""
read -p "Zadej domenu (napr. app.mojedomena.cz): " DOMAIN
read -p "Zadej email (pro HTTPS): " EMAIL

echo ""
echo "Domena: $DOMAIN"
echo "Email:  $EMAIL"
echo ""

# zjisti IP serveru
SERVER_IP=$(curl -s ifconfig.me)

echo "Kontroluji DNS..."

# čekání na DNS
for i in {1..30}; do
    DOMAIN_IPS=$(dig +short $DOMAIN)

    if echo "$DOMAIN_IPS" | grep -q "$SERVER_IP"; then
        echo "✅ DNS OK ($DOMAIN -> $SERVER_IP)"
        break
    fi

    if [ $i -eq 30 ]; then
        echo ""
        echo "❌ DNS NESOUHLASI!"
        echo "Domena nesmeruje na tento server"
        echo ""
        echo "➡ nastav A zaznam:"
        echo "$DOMAIN -> $SERVER_IP"
        exit 1
    fi

    echo "⏳ cekam na DNS... ($i/30)"
    sleep 10
done

# slozka
mkdir -p dbbrix
cd dbbrix

# .env
echo "Vytvarim .env..."
cat > .env <<EOF
DOMAIN=$DOMAIN
EMAIL=$EMAIL
EOF

# nginx.conf pro backend
echo "Generuji nginx.conf..."
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
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
EOF

# docker-compose
echo "Stahuji docker-compose.yml..."
curl -sSL https://raw.githubusercontent.com/MiroslavVasicek-git/DBBrix-installer/main/docker-compose.yml -o docker-compose.yml

# letsencrypt
mkdir -p letsencrypt
touch letsencrypt/acme.json
chmod 600 letsencrypt/acme.json

# restart (pro jistotu fresh install)
echo "Cistim stare kontejnery..."
docker compose down --remove-orphans || true

# start
echo "Spoustim aplikaci..."
docker compose pull
docker compose up -d --force-recreate

echo ""
echo "================================="
echo "Hotovo!"
echo "================================="
echo "Otevri: https://$DOMAIN"
echo ""
echo "⚠️ Pokud web nefunguje:"
echo "- pockej 1-2 minuty (certifikat)"
echo "- zkontroluj: docker logs dbbrix-traefik-1"
