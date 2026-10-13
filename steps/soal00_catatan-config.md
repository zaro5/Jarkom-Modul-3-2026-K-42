# Configurations

## Jichi

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 192.232.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 192.232.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 192.232.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 192.232.4.1
    netmask 255.255.255.0

up sysctl -w net.ipv4.ip_forward=1
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

up apt-get update
up apt-get install -y isc-dhcp-relay
```

## Tengen

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.232.4.10
    netmask 255.255.255.0
    gateway 192.232.4.1
    up echo -e 'nameserver 192.232.4.1\nnameserver 192.168.122.1\nnameserver 8.8.8.8' > /etc/resolv.conf

up apt-get update
up apt-get install isc-dhcp-server -y
```

## Utahime

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.232.1.2
    netmask 255.255.255.0
    gateway 192.232.1.1
    up echo -e 'nameserver 192.232.1.1\nnameserver 192.168.122.1\nnameserver 8.8.8.8' > /etc/resolv.conf
```

## Itadori

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

## Fushiguro

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

## Zenin

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

## Okkotsu

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

## Ino

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

## Kusakabe

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

## Miwa

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

## Kugisaki

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```