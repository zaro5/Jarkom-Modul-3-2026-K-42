#!/bin/bash
# Nomor 11 - DNS Master (utahime, 192.232.1.2)
set -e

DOMAIN="jujutsu.k42.com"
MASTER_IP="192.232.1.2"
SLAVE_IP="192.232.1.3"
GOJO_IP="192.232.1.4"
ZONE_DIR="/etc/bind/zones"
ZONE_FILE="$ZONE_DIR/db.$DOMAIN"

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

# 3. Deklarasi zona sebagai master
cat > /etc/bind/named.conf.local << LOC
zone "$DOMAIN" {
    type master;
    file "$ZONE_FILE";
    notify yes;
    also-notify { $SLAVE_IP; };
    allow-transfer { $SLAVE_IP; };
};
LOC

# 4. File zona
mkdir -p "$ZONE_DIR"
cat > "$ZONE_FILE" << ZONE
\$TTL    604800
@       IN      SOA     ns1.$DOMAIN. admin.$DOMAIN. (
                        2026101401      ; Serial
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
@       IN      NS      ns1.$DOMAIN.
@       IN      NS      ns2.$DOMAIN.
ns1     IN      A       $MASTER_IP
ns2     IN      A       $SLAVE_IP
gojo    IN      A       $GOJO_IP
ZONE

chown -R bind:bind "$ZONE_DIR"

# 5. Validasi
named-checkconf
named-checkzone "$DOMAIN" "$ZONE_FILE"

# 6. Jalankan / reload named
if pgrep -x named >/dev/null; then
    rndc reload
else
    service named start 2>/dev/null || service bind9 start 2>/dev/null || named -u bind
fi

sleep 2
echo "=== Test lokal ==="
dig @127.0.0.1 $DOMAIN SOA +short
dig @127.0.0.1 $DOMAIN NS +short