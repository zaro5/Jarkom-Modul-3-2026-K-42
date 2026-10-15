#!/bin/bash
# Geto - Internal Load Balancer (192.232.4.2), melanjutkan nomor 15
# Pemakaian:  bash /root/geto-proxy.sh <tahap>
#   17 = WRR 3:1 + IP klien hanya dipercaya dari gojo (X-Real-IP / X-Forwarded-For)
#   18 = tahap 17 + kirara sebagai backup + passive health check + failover
set -e

STAGE="${1:-18}"
NANAMI_IP="${NANAMI_IP:-192.232.4.5}"
TODO_IP="${TODO_IP:-192.232.4.6}"
KIRARA_IP="${KIRARA_IP:-192.232.4.7}"
GOJO_IP="${GOJO_IP:-192.232.1.4}"          # satu-satunya proxy tepercaya

case "$STAGE" in
    17) FAIL_OPTS="";                             BACKUP_LINE="";                           S18=off ;;
    18) FAIL_OPTS="max_fails=2 fail_timeout=5s";  BACKUP_LINE="server ${KIRARA_IP}:80 backup;"; S18=on ;;
    *)  echo "Pemakaian: bash $0 <17|18>"; exit 1 ;;
esac

if ! command -v nginx >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    echo "nameserver 192.168.122.1" > /etc/resolv.conf
    apt-get update
    apt-get install -y nginx curl
fi

CONF=/etc/nginx/sites-available/loadbalancer
cat > "$CONF" << 'NGX'
log_format lb '$remote_addr -> $upstream_addr [$time_local] "$request" $status real=$client_ip ups="$upstream_status"';

# Proxy yang boleh menentukan IP klien
geo $trusted_proxy {
    default     0;
    __GOJO__    1;
}

# IP klien: dari X-Real-IP hanya jika koneksi datang dari proxy tepercaya dan isinya berupa IP
map "$trusted_proxy:$http_x_real_ip" $client_ip {
    "~^1:(?<rip>[0-9a-fA-F:.]+)$"    $rip;
    default                          $remote_addr;
}

# Rantai X-Forwarded-For: header lama hanya dipakai jika dari proxy tepercaya
map "$trusted_proxy:$http_x_forwarded_for" $xff_out {
    "~^1:(?<xff>[0-9a-fA-F:., ]+)$"  "$xff, $remote_addr";
    default                          $remote_addr;
}

upstream api_cluster {
    zone api_cluster 64k;
    server __NANAMI__:80 weight=3 __FAIL__;
    server __TODO__:80 weight=1 __FAIL__;
    __BACKUP__
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
        proxy_set_header X-Real-IP $client_ip;
        proxy_set_header X-Forwarded-For $xff_out;
        proxy_next_upstream error timeout http_502 http_503 http_504;   # S18
        proxy_next_upstream_tries 3;                                    # S18
        proxy_connect_timeout 2s;                                       # S18
        add_header X-Upstream-Server $upstream_addr always;
    }
}
NGX

sed -i "s|__GOJO__|$GOJO_IP|g; s|__NANAMI__|$NANAMI_IP|g; s|__TODO__|$TODO_IP|g; s|__FAIL__|$FAIL_OPTS|g; s|__BACKUP__|$BACKUP_LINE|g" "$CONF"
[ "$S18" = "on" ] || sed -i '/# S18$/s/^\( *\)/\1#/' "$CONF"

rm -f /etc/nginx/sites-enabled/default
ln -sf "$CONF" /etc/nginx/sites-enabled/loadbalancer

nginx -t
service nginx restart
sleep 1

echo "=== Tahap $STAGE: konfigurasi aktif ==="
sed -n '/^geo /,/^}/p;/^upstream api_cluster/,/^}/p' "$CONF"
grep -E 'proxy_next_upstream|proxy_connect_timeout' "$CONF" | sed 's/^ *//'

echo "=== Uji lokal (4 request) ==="
for i in 1 2 3 4; do
    curl -s "http://127.0.0.1/cek-geto/$i"; echo
done
: > /var/log/nginx/lb_access.log