#!/bin/bash

# Install
apt-get update && apt-get install -y isc-dhcp-server
apt-get install systemctl

# Config in
cat << 'EOF' > /etc/dhcp/dhcpd.conf
# Deklarasi subnet lokal Network 4
subnet 192.232.4.0 netmask 255.255.255.0 {
}

# Scope DHCP untuk Network 2
subnet 192.232.2.0 netmask 255.255.255.0 {
    range 192.232.2.10 192.232.2.50;
    option routers 192.232.2.1;
    option domain-name-servers 192.232.1.2, 8.8.8.8;
}

# Scope DHCP untuk Network 3
subnet 192.232.3.0 netmask 255.255.255.0 {
    range 192.232.3.10 192.232.3.50;
    option routers 192.232.3.1;
    option domain-name-servers 192.232.1.2, 8.8.8.8;
}
EOF

# isi interfaces yang dilayaniin
echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server
echo 'INTERFACESv6=""' >> /etc/default/isc-dhcp-server

# nyalain dhcp nya
systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server
systemctl status isc-dhcp-server

echo "Konfigurasi DHCP Server di tengen selesai!"