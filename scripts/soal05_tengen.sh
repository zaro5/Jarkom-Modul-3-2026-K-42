#!/bin/bash

cat << 'EOF' > /etc/dhcp/dhcpd.conf
# Deklarasi subnet lokal Network 4
subnet 192.232.4.0 netmask 255.255.255.0 {
}

# Network 2 untuk TAHAP 4
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

subnet 192.232.2.0 netmask 255.255.255.0 {
    option routers 192.232.2.1;
    option domain-name-servers 192.232.1.2, 8.8.8.8;

    pool {
        allow members of "dev-group";
        range 192.232.2.10 192.232.2.35;
    }

    pool {
        allow members of "support-group";
        range 192.232.2.70 192.232.2.95;
    }
}

# Network 3 untuk TAHAP 5
class "short-lease-group" {
    match if (
        substring(hardware, 1, 6) = 02:42:5b:aa:33:00 or 
        substring(hardware, 1, 6) = 02:42:30:59:6b:00
    );
}

class "long-lease-group" {
    match if (
        substring(hardware, 1, 6) = 02:42:8e:c4:83:00
    );
}

subnet 192.232.3.0 netmask 255.255.255.0 {
    option routers 192.232.3.1;
    option domain-name-servers 192.232.1.2, 192.232.1.3, 8.8.8.8;
    option domain-search "k42.com";

    # Pool Short Lease (30 Menit / 1800 detik) -> Ino & Kusakabe
    pool {
        allow members of "short-lease-group";
        range 192.232.3.10 192.232.3.89;
        default-lease-time 1800;
        max-lease-time 1800;
    }

    # Pool Long Lease (12 Jam / 43200 detik) -> Miwa
    pool {
        allow members of "long-lease-group";
        range 192.232.3.100 192.232.3.199;
        default-lease-time 43200;
        max-lease-time 43200;
    }
}
EOF

dhcpd -t -cf /etc/dhcp/dhcpd.conf

systemctl restart isc-dhcp-server
systemctl status isc-dhcp-server

echo "ANJAY! Konfigurasi Tahap 5 Berhasil!"