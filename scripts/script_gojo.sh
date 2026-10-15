#!/bin/bash
# Gojo - Public Reverse Proxy (192.232.1.4)
# Pemakaian:  bash /root/gojo-proxy.sh <tahap>
#   16 = Path-Based Routing saja
#   17 = + header X-Real-IP / X-Forwarded-For
#   19 = + proxy cache 10 menit + rate limiting /api (dipakai juga untuk nomor 20)
# Override opsional (env): HEADERS=on|off  CACHE=on|off  RATE_LIMIT=on|off  RATE=10r/s  BURST=5
#   contoh baseline nomor 20:  RATE_LIMIT=off bash /root/gojo-proxy.sh 19
set -e

STAGE="${1:-19}"
case "$STAGE" in
    16) D_HDR=off; D_CACHE=off; D_RL=off ;;
    17) D_HDR=on;  D_CACHE=off; D_RL=off ;;
    19) D_HDR=on;  D_CACHE=on;  D_RL=on  ;;
    *)  echo "Pemakaian: bash $0 <16|17|19>"; exit 1 ;;
esac
HEADERS="${HEADERS:-$D_HDR}"
CACHE="${CACHE:-$D_CACHE}"
RATE_LIMIT="${RATE_LIMIT:-$D_RL}"
RATE="${RATE:-10r/s}"
BURST="${BURST:-5}"

WEB1_IP="${WEB1_IP:-192.232.4.3}"     # maki
WEB2_IP="${WEB2_IP:-192.232.4.4}"     # panda
GETO_IP="${GETO_IP:-192.232.4.2}"     # internal load balancer
DOMAINS="${DOMAINS:-jujutsu.k42.com www.jujutsu.k42.com}"
CONF=/etc/nginx/sites-available/gojo

# 1. Instalasi (hanya jika belum ada)
if ! command -v nginx >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    echo "nameserver 192.168.122.1" > /etc/resolv.conf
    apt-get update
    apt-get install -y nginx curl
fi

# 2. Konfigurasi. Baris bertanda "# HDR", "# CACHE", "# RL" dinonaktifkan jika fiturnya off
cat > "$CONF" << 'NGX'
log_format gojo 'ip=$remote_addr time=[$time_local] req="$request" status=$status bytes=$body_bytes_sent rt=$request_time urt="$upstream_response_time" up="$upstream_addr" ups="$upstream_status" cache=$upstream_cache_status limit=$limit_req_status';

proxy_cache_path /var/cache/nginx/web_cache levels=1:2 keys_zone=web_cache:10m max_size=100m inactive=10m use_temp_path=off;   # CACHE
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=__RATE__;   # RL

upstream web_cluster {
    zone web_cluster 64k;
    server __WEB1__:80;
    server __WEB2__:80;
    keepalive 16;
}

upstream geto_lb {
    server __GETO__:80;
    keepalive 16;
}

server {
    listen 80;
    server_name __DOMAINS__;

    access_log /var/log/nginx/gojo_access.log gojo;

    location /api {
        proxy_pass http://geto_lb;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;                    # HDR
        proxy_set_header X-Forwarded-For $remote_addr;              # HDR
        proxy_set_header X-Forwarded-Proto $scheme;                 # HDR
        limit_req zone=api_limit burst=__BURST__ nodelay;           # RL
        limit_req_status 429;                                       # RL
    }

    location / {
        proxy_pass http://web_cluster;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;                    # HDR
        proxy_set_header X-Forwarded-For $remote_addr;              # HDR
        proxy_set_header X-Forwarded-Proto $scheme;                 # HDR
        proxy_cache web_cache;                                      # CACHE
        proxy_cache_valid 200 301 302 10m;                          # CACHE
        proxy_cache_key "$scheme$host$request_uri";                 # CACHE
        proxy_cache_lock on;                                        # CACHE
        add_header X-Cache-Status $upstream_cache_status always;    # CACHE
    }
}
NGX

sed -i "s|__WEB1__|$WEB1_IP|g; s|__WEB2__|$WEB2_IP|g; s|__GETO__|$GETO_IP|g; s|__DOMAINS__|$DOMAINS|g; s|__RATE__|$RATE|g; s|__BURST__|$BURST|g" "$CONF"

disable() { sed -i "/# $1\$/s/^\( *\)/\1#/" "$CONF"; }
[ "$HEADERS" = "on" ]    || disable HDR
[ "$CACHE" = "on" ]      || disable CACHE
[ "$RATE_LIMIT" = "on" ] || disable RL

# 3. Direktori cache (dikosongkan agar uji MISS/HIT bersih)
mkdir -p /var/cache/nginx/web_cache
rm -rf /var/cache/nginx/web_cache/*
chown -R www-data:www-data /var/cache/nginx

rm -f /etc/nginx/sites-enabled/default
ln -sf "$CONF" /etc/nginx/sites-enabled/gojo

# 4. Validasi dan jalankan
nginx -t
service nginx restart
sleep 1

# 5. Verifikasi
echo "=== Tahap $STAGE | HEADERS=$HEADERS CACHE=$CACHE RATE_LIMIT=$RATE_LIMIT (rate=$RATE burst=$BURST) ==="
echo "--- Direktif aktif ---"
grep -vE '^[[:space:]]*#|^[[:space:]]*$' "$CONF" | grep -E 'server_name|proxy_pass|proxy_set_header X-|limit_req|proxy_cache|add_header'
echo "--- Uji lokal (Host: jujutsu.k42.com) ---"
curl -s -o /dev/null -w '/     -> HTTP %{http_code}\n' -H 'Host: jujutsu.k42.com' http://127.0.0.1/
curl -s -o /dev/null -w '/api  -> HTTP %{http_code}\n' -H 'Host: jujutsu.k42.com' http://127.0.0.1/api/cek-gojo