#!/bin/bash
# Nomor 15 - Internal Load Balancer (geto, 192.232.4.2)
# Nginx upstream api_cluster: nanami (weight 3) dan todo (weight 1) - Weighted Round Robin
# Jalankan di geto:  bash /root/geto-lb.sh
set -e

NANAMI_IP="${NANAMI_IP:-192.232.4.5}"
TODO_IP="${TODO_IP:-192.232.4.6}"
W_NANAMI="${W_NANAMI:-3}"
W_TODO="${W_TODO:-1}"

# 1. Instalasi
export DEBIAN_FRONTEND=noninteractive
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update
apt-get install -y nginx curl

# 2. Konfigurasi load balancer
cat > /etc/nginx/sites-available/loadbalancer << 'NGX'
# Format log khusus: mencatat worker mana yang menerima tiap request
log_format lb '$remote_addr -> $upstream_addr [$time_local] "$request" $status';

upstream api_cluster {
    zone api_cluster 64k;                  # state round robin dipakai bersama semua proses nginx
    server __NANAMI_IP__:80 weight=__W_NANAMI__;
    server __TODO_IP__:80 weight=__W_TODO__;
}

server {
    listen 80 default_server;
    server_name _;

    access_log /var/log/nginx/lb_access.log lb;

    location / {
        proxy_pass http://api_cluster;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # Header bantu pembuktian: worker mana yang menjawab
        add_header X-Upstream-Server $upstream_addr always;
    }
}
NGX

sed -i "s|__NANAMI_IP__|${NANAMI_IP}|g; s|__TODO_IP__|${TODO_IP}|g; s|__W_NANAMI__|${W_NANAMI}|g; s|__W_TODO__|${W_TODO}|g" \
    /etc/nginx/sites-available/loadbalancer

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/loadbalancer /etc/nginx/sites-enabled/loadbalancer

# 3. Validasi dan jalankan
nginx -t
service nginx restart
sleep 2

# 4. Verifikasi awal: 4 request = satu siklus penuh (harus 3x nanami, 1x todo)
echo "=== Konfigurasi upstream aktif ==="
nginx -T 2>/dev/null | sed -n '/upstream api_cluster/,/^}/p'

echo "=== 4 request awal (satu siklus 3:1) ==="
for i in 1 2 3 4; do
    curl -s -D - -o /dev/null "http://127.0.0.1/cek-awal/$i" | tr -d '\r' | grep -iE '^HTTP/|x-upstream-server' | tr '\n' ' '
    echo
done

# bersihkan log uji awal agar hitungan pembuktian bersih
: > /var/log/nginx/lb_access.log