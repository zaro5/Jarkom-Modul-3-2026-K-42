#!/bin/bash
# Nomor 14 - Worker Frontend (maki, panda): Nginx + PHP-FPM
# Jalankan di maki dan panda:  bash /root/worker-web.sh
set -e

WEB_DOMAINS="${WEB_DOMAINS:-jujutsu.k42.com www.jujutsu.k42.com}"
WEB_ALLOW="${WEB_ALLOW:-192.232.1.4}"      # jalur proxy web: gojo (public reverse proxy)
WEB_ROOT="/var/www/web"

# 1. Instalasi
export DEBIAN_FRONTEND=noninteractive
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update
apt-get install -y nginx php-fpm curl

PHPV=$(ls /etc/php | sort -V | tail -1)
SOCK="/run/php/php${PHPV}-fpm.sock"
mkdir -p /run/php

# 2. Halaman frontend: menampilkan hostname
mkdir -p "$WEB_ROOT"
cat > "$WEB_ROOT/index.php" << 'PHP'
<?php
header('Content-Type: text/html; charset=utf-8');
$host = htmlspecialchars(gethostname());
?>
<!DOCTYPE html>
<html lang="id">
<head><meta charset="utf-8"><title>Jujutsu High - Frontend</title></head>
<body>
<h1>Jujutsu High Frontend</h1>
<p>Hostname: <b><?= $host ?></b></p>
<p>Server: <?= htmlspecialchars($_SERVER['SERVER_ADDR'] ?? '-') ?></p>
</body>
</html>
PHP
chown -R www-data:www-data "$WEB_ROOT"

# 3. Virtual host + pembatasan akses (hanya jalur proxy)
ALLOW_BLOCK=$(for ip in $WEB_ALLOW 127.0.0.1; do printf '    allow %s;\n' "$ip"; done)

cat > /etc/nginx/sites-available/web << NGX
server {
    listen 80 default_server;
    server_name ${WEB_DOMAINS};

    root ${WEB_ROOT};
    index index.php;

    # Hanya jalur proxy yang boleh mengakses worker ini
${ALLOW_BLOCK}
    deny all;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:${SOCK};
    }
}
NGX

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/web /etc/nginx/sites-enabled/web

# 4. Validasi dan jalankan
nginx -t
service php${PHPV}-fpm restart
service nginx restart
sleep 2

# 5. Verifikasi lokal
MYIP=$(ip -4 -o addr show dev eth0 | awk '{print $4}' | cut -d/ -f1)
echo "=== Hostname node: $(hostname) ($MYIP) ==="
echo "--- dari localhost (diizinkan, harus 200) ---"
curl -s -o /dev/null -w 'HTTP %{http_code}\n' http://127.0.0.1/
curl -s http://127.0.0.1/ | sed 's/<[^>]*>/ /g' | tr -s ' \n' ' '; echo
echo "--- dari IP sendiri $MYIP (bukan jalur proxy, harus 403) ---"
curl -s -o /dev/null -w 'HTTP %{http_code}\n' "http://$MYIP/"