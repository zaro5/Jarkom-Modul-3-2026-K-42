# Configurations

## Jichi


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

lama:

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.232.2.2
    netmask 255.255.255.0
    gateway 192.232.2.1
    up echo -e 'nameserver 192.232.2.1\nnameserver 192.168.122.1\nnameserver 8.8.8.8' > /etc/resolv.conf
```

baru:

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

## fushiguro

lama:
```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.232.2.3
    netmask 255.255.255.0
    gateway 192.232.2.1
    up echo -e 'nameserver 192.232.2.1\nnameserver 192.168.122.1\nnameserver 8.8.8.8' > /etc/resolv.conf
```

baru:

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

## zenin

lama:

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.232.2.4
    netmask 255.255.255.0
    gateway 192.232.2.1
    up echo -e 'nameserver 192.232.2.1\nnameserver 192.168.122.1\nnameserver 8.8.8.8' > /etc/resolv.conf
```

baru:

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

## okkotsu

lama:

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.232.2.5
    netmask 255.255.255.0
    gateway 192.232.2.1
    up echo -e 'nameserver 192.232.2.1\nnameserver 192.168.122.1\nnameserver 8.8.8.8' > /etc/resolv.conf

```

baru:

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

## ino

lama:

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.232.3.2
    netmask 255.255.255.0
    gateway 192.232.3.1
    up echo -e 'nameserver 192.232.3.1\nnameserver 192.168.122.1\nnameserver 8.8.8.8' > /etc/resolv.conf
```

## kusakabe

lama:

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.232.2.3
    netmask 255.255.255.0
    gateway 192.232.3.1
    up echo -e 'nameserver 192.232.3.1\nnameserver 192.168.122.1\nnameserver 8.8.8.8' > /etc/resolv.conf
```

## miwa

lama:

```bash
auto eth0
iface eth0 inet static
    address 192.232.3.5
    netmask 255.255.255.0
    gateway 192.232.3.1
    up echo -e 'nameserver 192.232.3.1\nnameserver 192.168.122.1\nnameserver 8.8.8.8' > /etc/resolv.conf
```