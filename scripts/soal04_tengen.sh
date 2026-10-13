#!/bin/bash

cat << 'EOF' > /etc/dhcp/dhcpd.conf
# Deklarasi subnet lokal Network 4
subnet 192.232.4.0 netmask 255.255.255.0 {
}

# Deklarasi Class untuk Pool di Network 2
class "dev-group" {
    match if (
        substring(hardware, 1, 6) = 02:42:46:c6:b0:00 or
        substring(hardware, 1, 6) = 02:42:48:f7:34:00
    );
}

class "support-group" {
    match if (
        substring(hardware, 1, 6) = 02:42:e5:18:88:00 or
        substring(hardware, 1, 6) = 02:42:08:a0:ea:00
    );
}

# Subnet utama Network 2 agar DHCP Relay dan Pool dikenali server
subnet 192.232.2.0 netmask 255.255.255.0 {
    option routers 192.232.2.1;
    option domain-name-servers 192.232.1.2, 8.8.8.8;

    # Pool 1 untuk itadori & fushiguro (Tim Dev)
    pool {
        allow members of "dev-group";
        range 192.232.2.10 192.232.2.35;
    }

    # Pool 2 untuk zenin & okkotsu (Tim Support)
    pool {
        allow members of "support-group";
        range 192.232.2.70 192.232.2.95;
    }

    # Rentang 192.232.2.36 - 192.232.2.69 sengaja dikosongkan (tidak ada pool)
}

# Deklarasi untuk Network 3 (jika diperlukan)
subnet 192.232.3.0 netmask 255.255.255.0 {
    range 192.232.3.10 192.232.3.50;
    option routers 192.232.3.1;
    option domain-name-servers 192.232.1.2, 8.8.8.8;
}
EOF

dhcpd -t -cf /etc/dhcp/dhcpd.conf

echo "[*] Merestart layanan isc-dhcp-server..."
systemctl restart isc-dhcp-server
systemctl status isc-dhcp-server 
echo "ANJAY! Konfigurasi Tengen Selesai!"