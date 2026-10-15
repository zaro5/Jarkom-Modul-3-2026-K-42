#!/bin/bash
# Nomor 17 - API menyimpan IP klien yang sudah diverifikasi
# Jalankan di nanami, todo, dan kirara:  bash /root/worker-api-clientip.sh
set -e

API_ROOT="/var/www/api"
TRUSTED_PROXIES="${TRUSTED_PROXIES:-192.232.4.2}"      # hanya geto

if [ ! -f "$API_ROOT/config.php" ]; then
    echo "ERROR: $API_ROOT/config.php belum ada. Jalankan worker-api.sh (nomor 14) dulu."
    exit 1
fi

# Daftar proxy yang alamat kliennya dipercaya
{
    echo "<?php"
    echo "// Header X-Real-IP / X-Forwarded-For hanya dipercaya jika koneksi datang dari alamat ini"
    echo "return ["
    for ip in $TRUSTED_PROXIES; do echo "    '$ip',"; done
    echo "];"
} > "$API_ROOT/trusted.php"

cat > "$API_ROOT/public/index.php" << 'PHP'
<?php
header('Content-Type: application/json');

$cfg     = require __DIR__ . '/../config.php';
$trusted = require __DIR__ . '/../trusted.php';
$host    = gethostname();

// IP klien: default alamat koneksi langsung. Header hanya dipakai jika koneksi dari proxy tepercaya
$peer     = $_SERVER['REMOTE_ADDR'] ?? '';
$client   = $peer;
$verified = false;
if (in_array($peer, $trusted, true)) {
    $cand = trim($_SERVER['HTTP_X_REAL_IP'] ?? '');
    if ($cand === '') {
        $xff  = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'] ?? '');
        $cand = trim($xff[0]);
    }
    if (filter_var($cand, FILTER_VALIDATE_IP)) {
        $client   = $cand;
        $verified = true;
    }
}

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
        'status'            => 'ok',
        'worker'            => $host,
        'logged'            => true,
        'log_id'            => (int) $pdo->lastInsertId(),
        'client_ip'         => $client,
        'peer'              => $peer,
        'via_trusted_proxy' => $verified,
        'path'              => $path,
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
PHPV=$(ls /etc/php | sort -V | tail -1)
service php${PHPV}-fpm reload >/dev/null 2>&1 || true

echo "=== $(hostname): uji lokal (peer 127.0.0.1 bukan proxy tepercaya, via_trusted_proxy harus false) ==="
curl -s http://127.0.0.1/cek-clientip; echo