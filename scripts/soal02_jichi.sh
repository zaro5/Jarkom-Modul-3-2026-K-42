#!/bin/bash

# INSTALL DHCP
apt-get update && apt-get install -y isc-dhcp-relay
apt-get install systemctl

# Masukin konfigurasi
cat << 'EOF' > /etc/default/isc-dhcp-relay
# What servers should the DHCP relay forward requests to?
SERVERS="192.232.4.8"

# On what interfaces should the DHCP relay serve DHCP requests?
INTERFACES="eth2 eth3 eth4"

# Additional options
OPTIONS=""
EOF

# Nyalain
systemctl restart isc-dhcp-relay
systemctl enable isc-dhcp-relay
systemctl status isc-dhcp-relay

echo "Konfigurasi DHCP Relay di jiji selesai!"