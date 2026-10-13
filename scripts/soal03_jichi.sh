#!/bin/bash

# ubah config nya
cat << 'EOF' > /etc/default/isc-dhcp-relay
# What servers should the DHCP relay forward requests to?
SERVERS="192.232.4.10"

# On what interfaces should the DHCP relay serve DHCP requests?
INTERFACES="eth2 eth3 eth4"

# Additional options
OPTIONS=""
EOF

# restart dan cek status
systemctl restart isc-dhcp-relay
systemctl enable isc-dhcp-relay
systemctl status isc-dhcp-relay

echo "Konfigurasi Tahap 3 di jichi selesai!"