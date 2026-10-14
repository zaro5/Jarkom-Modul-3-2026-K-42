#!/bin/bash
# Nomor 11 - DNS Slave (shoko, 192.232.1.3)
set -e

DOMAIN="jujutsu.k42.com"
MASTER_IP="192.232.1.2"
SLAVE_FILE="/var/cache/bind/db.$DOMAIN"

# 1. Persiapan & instalasi
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update
apt-get install -y bind9 bind9utils dnsutils

# 2. Options
cat > /etc/bind/named.conf.options << OPT
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    recursion yes;
    allow-recursion { 192.232.0.0/16; localhost; };
    allow-query { any; };
    dnssec-validation no;
    listen-on { any; };
    listen-on-v6 { none; };
};
OPT

# 3. Deklarasi zona sebagai slave
cat > /etc/bind/named.conf.local << LOC
zone "$DOMAIN" {
    type slave;
    masters { $MASTER_IP; };
    file "$SLAVE_FILE";
};
LOC

# 4. Validasi
named-checkconf

# 5. Jalankan / reload named
if pgrep -x named >/dev/null; then
    rndc reload
else
    service named start 2>/dev/null || service bind9 start 2>/dev/null || named -u bind
fi

# 6. Tunggu transfer zona (maks 10 detik), paksa retransfer jika belum ada
for i in $(seq 1 10); do
    [ -s "$SLAVE_FILE" ] && break
    sleep 1
done
if [ ! -s "$SLAVE_FILE" ]; then
    echo "File zona belum ada, mencoba retransfer..."
    rndc retransfer "$DOMAIN" || true
    sleep 3
fi

echo "=== Status zona di slave ==="
rndc zonestatus "$DOMAIN" || true
dig @127.0.0.1 $DOMAIN SOA +short
dig @127.0.0.1 $DOMAIN NS +short
ls -l /var/cache/bind/