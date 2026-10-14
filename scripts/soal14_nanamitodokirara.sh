#!/bin/bash
# Nomor 14 - Worker API (nanami, todo, kirara): Nginx + PHP-FPM, log request ke database yaga
# Jalankan di nanami, todo, dan kirara:  bash /root/worker-api.sh
set -e

API_DOMAINS="${API_DOMAINS:-api.jujutsu.k42.com}"
API_ALLOW="${API_ALLOW:-192.232.4.2}"      # hanya geto (internal load balancer)
API_ROOT="/var/www/api"

DB_HOST="${DB_HOST:-192.232.4.9}"          # yaga (DB Master)
DB_NAME="${DB_NAME:-db_shibuya_K42}"
DB_USER="${DB_USER:-k42_user}"
DB_PASS="${DB_PASS:-k42pass}"

# 1. Instalasi
export DEBIAN_FRONTEND=noninteractive
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update
apt-get install -y nginx php-fpm php-mysql curl mariadb-client

PHPV=$(ls /etc/php | sort -V | tail -1)
SOCK="/run/php/php${PHPV}-fpm.sock"
mkdir -p /run/php

# 2. Aplikasi API
mkdir -p "$API_ROOT/public"

cat > "$API_ROOT/config.php" << CFG
<?php
return [
    'host' => '${DB_HOST}',
    'name' => '${DB_NAME}',
    'user' => '${DB_USER}',
    'pass' => '${DB_PASS}',
];
CFG

cat > "$API_ROOT/public/index.php" << 'PHP'
<?php
header('Content-Type: application/json');

$cfg  = require __DIR__ . '/../config.php';
$host = gethostname();

$xff    = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? '';
$client = $xff !== '' ? trim(explode(',', $xff)[0]) : ($_SERVER['REMOTE_ADDR'] ?? '-');
$path   = substr($_SERVER['REQUEST_URI'] ?? '/', 0, 255);
$method = substr($_SERVER['REQUEST_METHOD'] ?? 'GET', 0, 10);

try {
    $pdo = new PDO(
        "mysql:host={$cfg['host']};dbname={$cfg['name']};charset=utf8mb4",
        $cfg['user'],
        $cfg['pass'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_TIMEOUT => 3]
    );
    $stmt = $pdo->prepare(
        'INSERT INTO request_logs (client_ip, request_path, http_method, status_code) VALUES (?, ?, ?, ?)'
    );
    $stmt->execute([$client, $path, $method, 200]);

    echo json_encode([
        'status'    => 'ok',
        'worker'    => $host,
        'logged'    => true,
        'log_id'    => (int) $pdo->lastInsertId(),
        'client_ip' => $client,
        'path'      => $path,
    ], JSON_UNESCAPED_SLASHES);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'status'  => 'error',
        'worker'  => $host,
        'logged'  => false,
        'message' => $e->getMessage(),
    ], JSON_UNESCAPED_SLASHES);
}
PHP
chown -R www-data:www-data "$API_ROOT"
chmod 640 "$API_ROOT/config.php"

# 3. Virtual host + pembatasan akses (hanya geto)
ALLOW_BLOCK=$(for ip in $API_ALLOW 127.0.0.1; do printf '    allow %s;\n' "$ip"; done)

cat > /etc/nginx/sites-available/api << NGX
server {
    listen 80 default_server;
    server_name ${API_DOMAINS};

    root ${API_ROOT}/public;
    index index.php;

    # Hanya geto (internal load balancer) yang boleh mengakses worker ini
${ALLOW_BLOCK}
    deny all;

    location / {
        try_files \$uri /index.php\$is_args\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:${SOCK};
    }
}
NGX

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/api /etc/nginx/sites-enabled/api

# 4. Validasi dan jalankan
nginx -t
service php${PHPV}-fpm restart
service nginx restart
sleep 2

# 5. Verifikasi lokal
MYIP=$(ip -4 -o addr show dev eth0 | awk '{print $4}' | cut -d/ -f1)
echo "=== Hostname node: $(hostname) ($MYIP) ==="

echo "--- Koneksi ke database yaga ($DB_HOST) ---"
mariadb -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT 1 AS koneksi_ok;" \
    || echo "PERINGATAN: koneksi ke yaga gagal, cek user/host/bind-address di yaga"

echo "--- API dari localhost (diizinkan, harus 200 dan logged:true) ---"
curl -s -w '\nHTTP %{http_code}\n' http://127.0.0.1/uji-lokal

echo "--- dari IP sendiri $MYIP (bukan geto, harus 403) ---"
curl -s -o /dev/null -w 'HTTP %{http_code}\n' "http://$MYIP/"