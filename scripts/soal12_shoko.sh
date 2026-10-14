#!/bin/bash
# Nomor 12 - Slave untuk zona reverse (shoko, 192.232.1.3)
# Jalankan di shoko:  bash /root/shoko-no12.sh
set -e

DOMAIN="jujutsu.k42.com"
MASTER_IP="192.232.1.2"
GOJO_IP="192.232.1.4"
REV_ZONE="1.232.192.in-addr.arpa"
REV_FILE="/var/cache/bind/db.192.232.1"

if ! grep -q "$REV_ZONE" /etc/bind/named.conf.local; then
cat >> /etc/bind/named.conf.local << LOC

zone "$REV_ZONE" {
    type slave;
    masters { $MASTER_IP; };
    file "$REV_FILE";
};
LOC
fi

named-checkconf

if pgrep -x named >/dev/null; then
    rndc reload
else
    service named start 2>/dev/null || service bind9 start 2>/dev/null || named -u bind
fi

for i in $(seq 1 10); do
    [ -s "$REV_FILE" ] && break
    sleep 1
done
if [ ! -s "$REV_FILE" ]; then
    echo "File zona reverse belum ada, mencoba retransfer..."
    rndc retransfer "$REV_ZONE" || true
    sleep 3
fi

echo "=== Status zona reverse di slave ==="
rndc zonestatus "$REV_ZONE" || true
echo "--- PTR ---";   dig @127.0.0.1 -x $GOJO_IP +short
echo "--- A apex ---"; dig @127.0.0.1 $DOMAIN A +short
echo "--- CNAME www ---"; dig @127.0.0.1 www.$DOMAIN CNAME +short
ls -l /var/cache/bind/