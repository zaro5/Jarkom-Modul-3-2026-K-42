#!/bin/bash
# Nomor 12 - A record apex, CNAME www, zona PTR, DNS Forwarder (utahime, 192.232.1.2)
# Jalankan di utahime:  bash /root/utahime-no12.sh
set -e

DOMAIN="jujutsu.k42.com"
MASTER_IP="192.232.1.2"
SLAVE_IP="192.232.1.3"
GOJO_IP="192.232.1.4"
ZONE_DIR="/etc/bind/zones"
ZONE_FILE="$ZONE_DIR/db.$DOMAIN"
REV_ZONE="1.232.192.in-addr.arpa"
REV_FILE="$ZONE_DIR/db.192.232.1"

if [ ! -f "$ZONE_FILE" ]; then
    echo "ERROR: $ZONE_FILE belum ada. Selesaikan nomor 11 dulu."
    exit 1
fi

# 1. DNS Forwarder ke gateway internet
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

# 2. A record apex + CNAME www (hapus dulu jika sudah ada agar tidak dobel)
sed -i -E '/^(@|www)[[:space:]]+IN[[:space:]]+(A|CNAME)[[:space:]]/d' "$ZONE_FILE"
printf '\n@       IN      A       %s\nwww     IN      CNAME   %s.\n' "$GOJO_IP" "$DOMAIN" >> "$ZONE_FILE"

# 3. Naikkan serial zona forward
CUR=$(grep -E ';[[:space:]]*Serial' "$ZONE_FILE" | awk '{print $1}')
NEW=$((CUR + 1))
sed -i -E "s/${CUR}([[:space:]]*;[[:space:]]*Serial)/${NEW}\1/" "$ZONE_FILE"
echo "Serial zona forward: $CUR -> $NEW"

# 4. Zona reverse (PTR)
mkdir -p "$ZONE_DIR"
cat > "$REV_FILE" << REV
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
4       IN      PTR     $DOMAIN.
REV

# 5. Deklarasi zona reverse (hanya jika belum ada)
if ! grep -q "$REV_ZONE" /etc/bind/named.conf.local; then
cat >> /etc/bind/named.conf.local << LOC

zone "$REV_ZONE" {
    type master;
    file "$REV_FILE";
    notify yes;
    also-notify { $SLAVE_IP; };
    allow-transfer { $SLAVE_IP; };
};
LOC
fi

chown -R bind:bind "$ZONE_DIR"

# 6. Validasi
named-checkconf
named-checkzone "$DOMAIN" "$ZONE_FILE"
named-checkzone "$REV_ZONE" "$REV_FILE"

# 7. Reload
if pgrep -x named >/dev/null; then
    rndc reload
else
    service named start 2>/dev/null || service bind9 start 2>/dev/null || named -u bind
fi

sleep 2
echo "=== Test lokal di utahime ==="
echo "--- A (apex) ---";   dig @127.0.0.1 $DOMAIN A +short
echo "--- CNAME www ---";  dig @127.0.0.1 www.$DOMAIN CNAME +short
echo "--- PTR ---";        dig @127.0.0.1 -x $GOJO_IP +short
echo "--- Forwarder (google.com) ---"
dig @127.0.0.1 google.com A +noall +comments +answer | grep -E 'status|flags|google' || true