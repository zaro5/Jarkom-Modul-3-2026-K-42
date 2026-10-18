# Jarkom-Modul-3-2026-K-42

## Anggota

| | Nama | NRP |
|---|---|---|
| 1 | Azita Zahwa Zahida Asmoro | 5027251058 |
| 2 | I Made Gyanendra Anand Wisnawa | 5027251072 |

## Set-Up Awal

### Catatan

eth1 (192.232.1.1)
- utahime: 192.232.1.2
- shoko: 192.232.1.3
- gojo: 192.232.1.3

eth4 (192.232.4.1)
- geto: 192.232.4.2
- maki: 192.232.4.3
- panda: 192.232.4.4
- nanami: 192.232.4.5
- todo: 192.232.4.6
- kirara: 192.232.4.7
- tengen: 192.232.4.8
- yaga: 192.232.4.9
- inumaki: 192.232.4.10

### Jichi

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

### Tengen

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

### Utahime

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

### Itadori

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

### Fushiguro

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

### Zenin

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

### Okkotsu

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

### Ino

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

### Kusakabe

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

### Miwa

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

### Kugisaki

```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

## Soal 1

![alt text](assets/01-struktur.png)

## Soal 2

#### Jichi

Pada `jichi`, lakukan instalasi `isc-dhcp-relay -y` untuk menjalankan soal 2.

Ubah isi file `/etc/default/isc-dhcp-relay` menjadi:

```bash
SERVERS="192.232.4.8"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
```

Kemudian nyalakan layanan DHCP-nya.

#### Tengen

Lakukan hal yang sama pada `tengen`, instalasi `apt-get install -y isc-dhcp-server` dan ubah configurasinya, kemudian nyalakan.

```bash
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
```

### Set Up

Untuk menjalankan nomor 2, jalankan script yang telah dibuat.

- `soal02_jichi.sh` pada node `jichi`
- `soal02_tengen.sh` pada node `tengen`

### Hasil

![alt text](assets/02-jichi-status-dhcp.png)
![alt text](assets/02-udhcp-itadori.png)

Dari tangkapan gambar diatas, dapat dilihat bahwa ketika *service* DHCP setelah di-restart, salah satu client, `Itadori` berhasil mendapatkan alamat IP-nya.

Dilakukan pengecekan pula bahwa node `Itadori` berhasil melakukan ping.

![alt text](assets/02-ping-192.232.4.5.png)

## Soal 3

Pada soal ini, diminta untuk mengkonfigurasikan `jichi` sebagai DHCP Relay menuju Tengen dengan IP `192.232.4.10` menggunakan eth2 dan eth3.

#### Tengen

Pada node `tengen`, masuk ke `/etc/network/interfaces` dan ubah address nya menjadi `192.232.4.10`. Pastikan gateawaynya masih `192.232.4.1`.

Setelahnya, restart ulang dhcp. Pastikan server running.

```bash
systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server
systemctl status isc-dhcp-server
```

#### Jichi

Ubah isi `/etc/default/isc/dhcp/relay` di bagian SERVERS menjadi `SERVERS="192.232.4.10".

### Set Up

Untuk menjalankan nomor 3, jalankan script yang telah dibuat.

- `soal03_jichi.sh` pada node `jichi`

### Hasil

![alt text](assets/03-ganti-address.png)
![alt text](assets/03-dhcp-active-jichi.png)

Dari gambar diatas, setelah dilakukan perubahan IP Address pada `Tengen`, DHCP di-restart dan dipastikan sudah dalam kondisi AKTIVE (RUNNING).

Setelah berhasil, dilakukan pengujian terhadap client.

![alt text](assets/03-tes-itadori.png)

Dari uji coba tersebut, dapat dipastikan bahwa client berhasil mendapatkan *lease* melalui relay.

## Soal 4

Pada soal ini, diminta untuk menetapkan Pool 1 (Tim Dev) untuk `itadori` dan `fushiguro`, sementara Pool 2 (Support) untuk `zenin` dan `okkotsu`. Ini dilakukan dengan catatan bahwa IP `192.232.2.36` - `192.232.2.69` tidak boleh dialokasikan.

#### Tengen

Masukkan alamat MAC ke `/etc/dhcp/dhcpd.conf` dari masing-masing node di Network 2, yakni `itadori`, `fushiguro`, `zenin`, dan `okkotsu`.

```bash
ip a
```

Gunakan perintah di atas untuk melakukan pengecekan MAC di masing-masing node.

Dari perintah tersebut, didapat alamat MAC sebagai berikut:

*(Data dari alamat MAC dapat berubah!)*

- itadori

```bash
02:42:46:c6:b0:00
```

- fushiguro

```bash
02:42:48:f7:34:00
```

- zenin

```bash
02:42:e5:18:88:00
```

- okkotsu

```bash
02:42:08:a0:ea:00
```

#### Jichi

Pada node `jichi`, pastikan dhcp sudah running dengan tanda ACTIVE.

### Set Up

Untuk menjalankan soal 4, jalankan script pada masing-masing node.

- `soal04_jichi.sh` pada `jichi`
- `soal04_tengen.sh` pada `tengen`

### Hasil

![alt text](../assets/04-tengen-dhcp.conf.png)

Pada file `dhcpd.conf` diatas, dapat dilihat bahwa MAC sudah sesuai dengan MAC masing-masing dari node.

![alt text](../assets/04-tengen-dhcp-restart.png)
![alt text](../assets/04-jichi-dhcp-rstart.png)

Apabila layanan DHCP dari `Tengen` dan `Itadori` sudah berstatus ACTIVE, jalankan pengujian pada seluruh client menggunakan `udhcpc`.

```bash
udhcpc -i eth0
```

![alt text](../assets/04-udhcp-itadori.png)
![alt text](../assets/04-udhcp-fushi.png)
![alt text](../assets/04-udhcp-zenin.png)
![alt text](../assets/04-udhcp-okkotsu.png)

Dari hasil `udhcpc` diatas, dapat dilihat bahwa masing-masing client berhasil memperoleh IP Address melalui relay.


## Soal 5

# Langkah-Langkah

## Penjelasan Awal

Pada soal ini, diminta untuk memberikan *short lease* pada `ino` dan `kusakabe`, serta *long lease* kepada `miwa`.

Perlu juga untuk memberikan DHCP options berupa `192.232.1.2`, `192.232.1.3`, dan domain-search `k42.com`.

### Jinchi

Pada node `jichi`, pastikan dhcp sudah berjalan dengan status `Active: active (running)`

```bash
systemctl restart isc-dhcp-relay
systemctl enable isc-dhcp-relay
systemctl status isc-dhcp-relay
```

### Tengen

Pada node `tengen`, masukkan alamat MAC dari semua node Network 3 (kecuali Kugisaki). Dengan `ino` dan `kusakabe` diberikan *short lease* dan `miwa` diberikan *long lease*. Ambil alamat MAC dengan menggunakan `ip a`.

```bash
ip a
```

- **Ino**

```bash
02:42:5b:aa:33:00
```

![alt text](../assets/05-MAC-ino.png)

- **Kusakabe**

```bash
02:42:30:59:6b:00
```

![alt text](../assets/05-MAC-kusakabe.png)

- **Miwa**

```bash
02:42:8e:c4:83:00
```

![alt text](../assets/05-MAC-miwa.png)

## Set Up

Untuk menjalankan soal 5, jalankan script pada node `tengen` saja.

- `soal05_tengen.sh` pada `tengen`

## Hasil

![alt text](../assets/05-dchpd.conf.png)
![alt text](../assets/05-restart-jichi.png)
![alt text](../assets/05-restart-tengen.png)

Dari file `dhcpd.conf` diatas, dapat dilihat bahwa semua persyaratan yang diminta sudah sesuai. Setelah *restart* DHCP berhasil, dilakukan pengujian terhadap client.

![alt text](../assets/05-udhcp-ino.png)
![alt text](../assets/05-udhcp-kusakabe.png)
![alt text](../assets/05-udhcp-miwa.png)


## Soal 6

# Langkah-Langkah

## Penjelasan Awal

Pada soal ini diminta untuk menetapkan *fixed address* `192.232.3.99` untuk client `Kugisaki`.

### Jichi

Pada node `jichi` tidak perlu melakukan perubahan apapun. Cukup pastikan DHCP berjalan dengan status AKTIVE (RUNNING).

### Tengen

Pada node `tengen`, masukkan alamat MAC `kugisaki` dan set untuk *static lease* nya ke dalam file `/etc/dhcp/dhcpd.conf`

```bash
nano /etc/dhcp/dhcpd.conf
```

```bash
# Static Lease / Reservasi VIP untuk Kugisaki
    host kugisaki {
        hardware ethernet 02:42:80:03:5c:00; # Ini MAC Kugisaki
        fixed-address 192.232.3.99;
    }
```

Pastikan letak *static lease*-nya berada dibawah *long lease*.

![alt text](../assets/06-dhcp.conf-tahap-6.png)

## Set Up

Pada soal 6 tdiak perlu running script, cukup nyalakan DHCP dan restart dari node `tengen` dan `jichi`.

- jichi

```bash
systemctl restart isc-dhcp-relay
systemctl enable isc-dhcp-relay
systemctl status isc-dhcp-relay
```

- tengen

```bash
systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server
systemctl status isc-dhcp-server
```

## Hasil

Setelah berhasil melakukan *restart* pada DHCP Relay dan DHCP Server tanpa error, lakukan uji coba pada client `Kugisaki`.

![alt text](../assets/06-udhcp-kugisaki.png)

Dari hasil `udhcpc` yang dilakukan pada `Kugisaki`, dapat dilihat bahwa node client berhasil menerima IP Address statis.


## Soal 7

# Langkah-Langkah

## Penjelasan Awal

### Jichi

Pada node `jichi` sama seperti sebelumnya, tidak ada set-up sama sekali, namun cukup memastikan bahwa DHCP berada dalam status ACTIVE (RUNNING).

```bash
systemctl restart isc-dhcp-relay
systemctl enable isc-dhcp-relay
systemctl status isc-dhcp-relay
```

### Tengen

Pada node `tengen` juga tidak perlu melakukan perubahan yang besar. Namun pastikan alamat MAC dari node yang ada pada `/etc/dhcp/dhcpd.conf` masih sama dengan alamat MAC pada masing-masing node.

```bash
systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server
systemctl status isc-dhcp-server
```

Untuk melakukan pengecekan apakah isi dari MAC Address di `/etc/dhcp/dhcpd.conf` sudah sesuai atau belum, gunakan perintah ini:

```bash
ip a 
```

### Catatan

Apabila output mengeluarkan `broadcasting discover`, jalankan perintah `stop` di `Tengen`.

![alt text](../assets/07-error-udhcp.png)

```bash
systemctl stop isc-dhcp-server   # Untuk menghentikan DHCP
dhcpd -f -d -cf /etc/dhcp/dhcpd.conf   # Untuk menjalankan ulang

## Apabila sudah berhasil, lakukan ctrl + C untuk menghentikan perintah
```

## Hasil

Lakukan pengujian terhadap perwakilan dari masing-masing grup. Pastikan IP yang dihasilkan sesuai dengan yang diminta. (lihat soal-soal sebelummnya)

- itadori (`192.232.2.10` - `192.232.2.35`)
![alt text](../assets/07-udhcp-tes-itadori.png)

- zenin (`192.232.2.70` - `192.232.2.95`)
![alt text](../assets/07-udhcp-tes-zenin.png)

- ino (`192.232.3.10` - `192.232.3.89`)
![alt text](../assets/07-udhcp-tes-ino.png)

- kugisaki (`192.232.3.99`)
![alt text](../assets/07-udhcp-tes-kugisaki.png)

- miwa (`192.232.3.100` - `192.232.3.199`)
![alt text](../assets/07-udhcp-tes-miwa.png)


## Soal 8

# Langkah-Langkah

## Persiapan Awal

### Jichi dan Tengen

Tidak ada persiapan yang spesifik, cukup melakukan restart terhadap dhcp yang ada, dan pada `tengen`, pastikan alamat MAC sudah sesuai dengan masing-masing node yang akan di uji.

- Jichi

```bash
systemctl restart isc-dhcp-relay
systemctl enable isc-dhcp-relay
systemctl status isc-dhcp-relay
```

- Tengen

```bash
systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server
systemctl status isc-dhcp-server
```

Cek alamat MAC:

```bash
cat /etc/dhcp/dhcpd.conf
nano /etc/dhcp/dhcpd.conf
```

## Set Up

Tidak ada script yang harus dijalankan. Namun cukup jalankan `tcpdump` pada `Tengen` untuk melakukan pengecekan `DHCPDISCOVER` `DHCPOFFER` `DHCPREQUEST` `DHCPACK`

```bash
tcpdump -i eth0 -vvv -nn port 67 or port 68
```

### Catatan

Apabila output mengeluarkan `broadcasting discover`, jalankan perintah `stop` di `Tengen`.

![alt text](../assets/07-error-udhcp.png)

```bash
systemctl stop isc-dhcp-server   # Untuk menghentikan DHCP
dhcpd -f -d -cf /etc/dhcp/dhcpd.conf   # Untuk menjalankan ulang

## Apabila sudah berhasil, lakukan ctrl + C untuk menghentikan perintah
```

Jika `udhcpc` berhasil dijalankan di clinet, nyalakan ulang `tcpdump`.

## Hasil

### Itadori

![alt text](../assets/08-1-itadori-dis.png)
![alt text](../assets/08-1-itadori-off.png)
![alt text](../assets/08-1-itadori-req.png)
![alt text](../assets/08-1-itadori-ack.png)

Dari hasil tangkapan diatas, di dapatkan detail parameter jaringannya:

- Alamat server: `192.232.4.10`
- Alamat yang diberikan: `192.232.2.12`
- Lease time: `42490`
- Field giaddr: `192.232.2.1`

### Zenin

![alt text](../assets/08-2-zenin-dis.png)
![alt text](../assets/08-2-zenin-off.png)
![alt text](../assets/08-2-zenin-req.png)
![alt text](../assets/08-2-zenin-ack.png)

Dari hasil tangkapan diatas, di dapatkan detail parameter jaringannya:

- Alamat server: `192.232.4.10`
- Alamat yang diberikan: `192.232.2.70`
- Lease time: `42037`
- Field giaddr: `192.232.2.1`

### Ino

![alt text](../assets/08-3-ino-dis.png)
![alt text](../assets/08-3-ino-off.png)
![alt text](../assets/08-3-ino-req.png)
![alt text](../assets/08-3-ino-ack.png)

Dari hasil tangkapan diatas, di dapatkan detail parameter jaringannya:

- Alamat server: `192.232.4.10`
- Alamat yang diberikan: `192.232.3.11`
- Lease time: `41941`
- Field giaddr: `192.232.3.1`

### Miwa

![alt text](../assets/08-4-miwa-dis.png)
![alt text](../assets/08-4-miwa-off.png)
![alt text](../assets/08-4-miwa-req.png)
![alt text](../assets/08-4-miwa-ack.png)

Dari hasil tangkapan diatas, di dapatkan detail parameter jaringannya:

- Alamat server: `192.232.4.10`
- Alamat yang diberikan: `192.232.3.100`
- Lease time: `43192`
- Field giaddr: `192.232.3.1`

### Kugisaki

![alt text](../assets/08-5-kugisaki-dis.png)
![alt text](../assets/08-5-kugisaki-off.png)
![alt text](../assets/08-5-kugisaki-req.png)
![alt text](../assets/08-5-kugisaki-ack.png)

Dari hasil tangkapan diatas, di dapatkan detail parameter jaringannya:

- Alamat server: `192.232.4.10`
- Alamat yang diberikan: `192.232.3.99`
- Lease time: `43200`
- Field giaddr: `192.232.3.1`


## Soal 9

# Langkah-Langkah

## Penjelasan Awal

Pada soal 9, diminta untuk melakukan pengujian untuk request permintaan alamat IP apabila DHCP dimatikan.

Tidak ada persiapan yang spesifik untuk penyelesaian nomor ini. Cukup pastikan DHCP dalam keadaan aktif sebelum pengujian dilakukan.

- Jichi

```bash
systemctl restart isc-dhcp-relay
systemctl enable isc-dhcp-relay
systemctl status isc-dhcp-relay
```

- Tengen

```bash
systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server
systemctl status isc-dhcp-server
```

## Set Up

Pada soal ini tidak ada script yang harus dijalankan. Hanya berupa perintah yang dijalankan di terminal secara langsung.

Matikan DHCP dari node `jichi` untuk melakukan pengujian.

```bash
systemctl stop isc-dhcp-server
```

Kemudian pindah ke node client, `itadori`. Minta alamat IP secara paksa.

```bash
udhcpc -i eth0 -n -s /usr/share/udhcpc/default.script
```

Selanjutnya, nyalakan kembali DHCP, dan minta alamat IP dengan cara normal.

```bash
# Jalankan di JICHI
systemctl start isc-dhcp-relay
systemctl status isc-dhcp-relay

# Jalankan di ITADORI
udhcpc -i eth0 -n
```

## Hasil

Dari uji coba yang telah dijalnkan, ketika `itadori` (client) meminta secara paksa dengan kondisi DHCP sedang dimatikan, tidak akan ada balasan yang datang.

![alt text](../assets/09-jichi-stop.png)
![alt text](../assets/09-itadori-paksa.png)

Output `udhcpc: broadcasting discover` menunjukkan bahwa tidak ada balasan yang datang dari `jichi`. Hal ini dikarenakan service DHCP pada `jichi` telah dimatikan, sehingga paket broadcast `DISCOVER` dari *client* hanya akan berputar di subnet lokal saja.

![alt text](../assets/09-jichi-restart.png)
![alt text](../assets/09-itadori-minta-normal.png)

Setelah service DHCP dinyalakan, `itadori` mendapatkan output `udhcpd: broadcasting select`. Ini menandaan bahwa *client* berhasil mendapatkan balasan dari DHCP (`jichi`). Hal ini dikarenakan pulihnya perantara komunikasi antar subnet.

## Soal 10

# Langkah-Langkah

## Penjelasan Awal

Pada soal ini diminta untuk memastikan DHCP Server dan DHCPP Jichi telah mengaktifkan `autostart`. Hal ini bertujuan agar seluruh layanan pendukung akan langsung aktif secara otomatis ketika server dihidupkan ulang. 

## Tengen

Pada node `Tengen` tidak perlu melakukan persiapan yang terlalu rumit. Cukup pastikan server DHCP telah menyala.

```bash
# Untuk melakukan pengecekan
systemctl status isc-dhcp-server
```

## Jichi

Pada node `Jichi` tidak perlu melakukan persiapan yang terlalu rumit. Cukup pastikan server DHCP telah menyala.

```bash
# Untuk melakukan pengecekan
systemctl status isc-dhcp-relay
```

## Set Up

Tidak ada script yang harus dijalankan. Cukup jalankan perintah pada terminal saja.

Jalankan perintah `enable` pada kedua node agar dapat menyalakan autostart yang diminta pada soal.

```bash
# Pada TENGEN
systemctl enable isc-dhcp-server
systemctl restart isc-dhcp-server
systemctl status isc-dhcp-server

# Pada JICHI
systemctl enable isc-dhcp-relay
systemctl restart isc-dhcp-relay
systemctl status isc-dhcp-relay
```

## Hasil

Setelah node berhasil dilakukan`enable` dan `restart`,  lakukan pengecekan pada masing-masing client.

![alt text](../assets/10-itadori.png)
![alt text](../assets/10-zenin.png)
![alt text](../assets/10-ino.png)
![alt text](../assets/10-miwa.png)
![alt text](../assets/10-kugisaki.png)

## Soal 11

# Langkah-Langkah

## Penjelasan Awal
Pada soal ini kita disuruh untuk membuat domain resmi dengan konfigurasi BIND9 pada node Utahime sebagai DNS masternya dan node Shoko sebagai DNS slavenya untuk mengelola domain jujutsu.k42.com. Kita diperlukan untuk mengatur SOA record, NS delegasi kedua server, dan terapkan allow-transfer dari Master ke Slave. Dan juga kita diperlukan supaya file zona berhasil tersinkronasi otomatis ke shoko saat serial di utahime dinaikkan. (Mirip seperti node prab dan tedd pada modul sebelumnya.)

### Pendahuluan
Sebelum memulai pengerjaan, kita uji coba konektivitas dasar antar node utahime dan shoko agar aman. Lakukanlah kedua ini pada kedua node tersebut.
```
ip a
ip route
ping -c 2 192.232.1.1        # gateway (jichi)
ping -c 2 192.168.122.1      # akses keluar untuk apt
ping -c 2 192.232.1.3        # utahime <-> shoko
```

Hasil:
![alt text](../assets/11-pendahuluanutahime.png)
![alt text](../assets/11-pendahuluanshoko.png)

Setelah aman, maka mari kita mulai pengerjaannya.

### Utahime
Jalankan script `soal11_utahime.sh` terlebih dahulu. Jika sudah dijalankan dan benar, akan menghasilkan berikut:
![alt text](../assets/11-utahimeberhasil.png)

### Shoko
Jalankan script `soal11_shoko.sh` untuk menjalankan setup slave dan juga sekaligus melakukan transfer zona dan mengecek apakah slave berhasil mengambil dari master. Hasilnya seperti berikut:
![alt text](../assets/11-shokoberhasil.png)

Disini terlihat bahwa slave berhasil mengambil nama zonanya sebagai jujutsu.k42.com dan memperlihatkan bahwa serial zona adalah 401. Setelah itu, juga berhasil terlihat transfer zona yang dilakukan yang terjadi pada `14 Oktober pada pukul 09:00`

### Verifikasi
Untuk mengecek apakah slave melakukan sinkronisasi otomatis secara serial dinaikkan, kita lakukan pengetesan berikut:
```
# Di utahime
dig @127.0.0.1 jujutsu.k42.com SOA +short
sed -i 's/2026101401\(\s*; Serial\)/2026101402\1/' /etc/bind/zones/db.jujutsu.k42.com
named-checkzone jujutsu.k42.com /etc/bind/zones/db.jujutsu.k42.com
rndc reload jujutsu.k42.com

# Di shoko, tunggu 3-5 detik
dig @127.0.0.1 jujutsu.k42.com SOA +short
ls -l /var/cache/bind/
```

![alt text](../assets/11-utahimenaikserial.png)
![alt text](../assets/11-shokonaikserial.png)

Disini terlihat bahwa serial berhasil melakukan sinkronisasi otomatis dimana saat utahime menaikkan serial zona menjadi 402, shoko juga ikut menaikkan serial menjadi 402.

Dan terakhir kita diminta untuk melakukan query dig ke kedua server melalui salah satu klient, maka kita uji coba dig dengan menggunakan misalnya node itadori.
```
# Di itadori
apk add --no-cache bind-tools
dig @192.232.1.2 jujutsu.k42.com SOA
dig @192.232.1.3 jujutsu.k42.com SOA
dig @192.232.1.2 jujutsu.k42.com NS
dig @192.232.1.3 jujutsu.k42.com NS
```

![alt text](../assets/11-queryitadori.png)

Disini terlihat bahwa di node itadori ia berhasil melakukan dig dan menampilkan nama zonanya yaitu jujutsu.k42.com serta nomor serial dari zona tersebut.

Dengan ini, soal 11 selesai.

## Soal 12

# Langkah-Langkah

## Penjelasan Awal
Kita diperlukan untuk menambahkan record yang mengarah ke node gojo (sudah pada nomor sebelumnya), serta CNAME yang merujuk ke domain utama tersebut. Lalu kita membuat reverse dns (zona ptr) untuk melacak IP gojo kembali ke domain resminya. Terakhir kita uji dari client dengan dig.

### Utahime
Jalankan script `soal12_utahime.sh`
![alt text](../assets/12-utahimescript.png)

Disini terlihat bahwa verifikasi yang berada di dalam scriptnya menghasilkan jawaban yang benar dan berhasil mengupdate dan membuat reverse dnsnya serta menaikkan forwardernya (google).

### Shoko
Jalankan script `soal12_shoko.sh`
![alt text](../assets/12-shokoscript.png)

Disini terlihat jika slave berhasil menarik dari master.

### Validasi
Untuk melakukan validasi, kita uji coba di node itadori.
```
apk add --no-cache bind-tools

# CNAME
dig @192.232.1.2 www.jujutsu.k42.com
dig @192.232.1.3 www.jujutsu.k42.com

# PTR
dig @192.232.1.2 -x 192.232.1.4
dig @192.232.1.3 -x 192.232.1.4

# Forwarder
dig @192.232.1.2 google.com

# Ping domain internet
ping -c 3 google.com
```

![alt text](../assets/12-verifikasiberhasil2.png)
![alt text](../assets/12-verifikasiberhasil.png)

Kita bisa melihat bahwa dignya menghasilkan CNAME, PTR jujutsu.k42.com, dan dig google.com menghasilkan no error dan berhasil di ping.

Dengan itu, soal 12 sudah selesai.

## Soal 13

# Langkah-Langkah

## Penjelasan Awal
Nomor ini mirip seperti nomor 11, bedanya kita membuat DB menggunakan MariaDB pada node yaga sebagai DB-Master dan inumaki sebagai DB-Slave. Kita disuruh untuk membuat database db_shibuya_k42 beserta tabel request_logs di master, lalu aktifkan binary logging. Setelah itu inumaki sebagai slave harus bisa menyalin data secara realtime dengan CHANGE MASTER TO. Kita juga perlu untuk memberikan hak akses remote bagi seluruh node di network 4 dan melakukan pembuktian slave.

### Pendahuluan
Kita pertama mengecek konektivitas di yaga dan inumaki terlebih dahulu.
```
ping -c 2 192.232.4.1          # gateway (jichi)
ping -c 2 192.168.122.1        # akses keluar untuk apt
```

![alt text](../assets/13-yagaberhasil.png)
![alt text](../assets/13-inumakiberhasil.png)

Disini terlihat bahwa ping berhasil, maka kita mulai pengerjaannya.

### Yaga
Jalankan script `soal13_yaga.sh`.
![alt text](../assets/13-scriptyaga.png)

Disini kita bisa melihat tabel request_logs yang berhasil dibuat dan port 3306 yang listen di 0.0.0.0.

### Inumaki
Jalankan script `soal13_inumaki.sh`
![alt text](../assets/13-scriptinumaki.png)

Disini kita bisa melihat kedua statusnya mengembalikan YES serta database dan tabel yang sudah muncul di slave.

### Validasi
Untuk mengetes apakah replikasi berjalan secara realtime, kita lakukan berikut.

Di Yaga:
```
mariadb -e "INSERT INTO db_shibuya_K42.request_logs (client_ip, request_path, http_method, status_code)
            VALUES ('192.232.2.10', '/api/curse/test', 'GET', 200);"
mariadb -e "SELECT * FROM db_shibuya_K42.request_logs;"
```

Di Inumaki
```
mariadb -e "SELECT * FROM db_shibuya_K42.request_logs;"
```

![alt text](../assets/13-verifikasiyaga.png)
![alt text](../assets/13-verifikasiinumaki.png)

Disini terlihat bahwa Inumaki berhasil untuk melakukan replikasi secara realtime yang bisa dilihat lewat pembuatan baris baru di tabel request_logs lewat Yaga yang berhasil di replikasi oleh Inumaki.

Lalu kita melakukan pembuktian hak akses remote Network 4.

Pada Geto (Tidak harus Geto, asalkan nodenya berada pada remote network 4.):
```
apt-get update && apt-get install -y mariadb-client
mariadb -h 192.232.4.9  -u k42_user -pk42pass -e "SELECT USER(), @@hostname; SHOW DATABASES;"
mariadb -h 192.232.4.10 -u k42_user -pk42pass -e "SELECT USER(), @@hostname; SHOW DATABASES;"

# Jalankan ini setelahnya
mariadb -h 192.232.4.9 -u k42_user -pk42pass -e "SELECT 1;"
```

![alt text](../assets/13-verifikasigeto.png)
![alt text](../assets/13-verifikasigeto2.png)

Disini kita bisa melihat bahwa kita bisa melihat databasenya dan login sukses dari node Network 4 ke Master dan Slave.

Dengan ini, soal 13 sudah selesai.

## Soal 14

# Langkah-Langkah

## Penjelasan Awal
Pada soal ini kita diperlukan untuk pasang Nginx dan PHP-FPM pada maki dan panda untuk menyajikan web frontend yang menampilkan hostname masing-masing. Pada nanami, todo, dan kirara, siapkan layanan API yang mencatat log request ke database yaga. Konfigurasikan virtual host agar worker merespons domain layanan yang ditentukan. Batasi akses langsung dari klien ke worker, web worker hanya menerima trafik melalui jalur proxy web yang ditentukan, sedangkan worker API hanya menerima trafik melalui geto.

### Node Worker Web (Maki dan Panda)
Jalankan script `soal14_makipanda.sh` di node masing-masing.

![alt text](../assets/14-scriptmaki.png)
![alt text](../assets/14-scriptpanda.png)

Disini terlihat bahwa script berhasil terjalan tanpa error.

### Node Worker API (Nanami, Todo, Kirara)
Jalankan script `soal14_nanamitodokirara.sh` di node masing-masing.

![alt text](../assets/14-scriptnanami.png)
![alt text](../assets/14-scripttodo.png)
![alt text](../assets/14-scriptkirara.png)

Disini terlihat bahwa script berhasil terjalan tanpa error.

### Verifikasi
Setelah semuanya terjalan, kita mulai untuk verifikasi akses langsung dari klien ditolak. Untuk verifikasi ini, kita menggunakan node random, misal ino.

Di Ino:
```
curl -i http://192.232.4.3/                                      # maki   -> 403
curl -i http://192.232.4.4/                                      # panda  -> 403
curl -i http://192.232.4.5/                                      # nanami -> 403
curl -i http://192.232.4.6/                                      # todo   -> 403
curl -i http://192.232.4.7/                                      # kirara -> 403
curl -i -H "Host: jujutsu.k42.com" http://192.232.4.3/           # tetap 403 meski Host benar
curl -i -H "Host: api.jujutsu.k42.com" http://192.232.4.5/       # tetap 403
```

![alt text](../assets/14-verifikasiino.png)

Disini terlihat bahwa semua curl menghasilkan 403 forbidden yang berarti akses langsung dari klien ditolak berhasil.

Berikut kita coba akses lewat jalur proxy berhasil melalui node gojo (jalur web) dan geto (jalur api).

Di Gojo:
```
curl -s -H "Host: jujutsu.k42.com" http://192.232.4.3/
curl -s -H "Host: jujutsu.k42.com" http://192.232.4.4/
```

![alt text](../assets/14-verifikasigojo.png)

Disini terlihat bahwa gojo berhasil untuk mengecurl.

Di Geto:
```
curl -s -H "Host: api.jujutsu.k42.com" http://192.232.4.5/uji-geto ; echo
curl -s -H "Host: api.jujutsu.k42.com" http://192.232.4.6/uji-geto ; echo
curl -s -H "Host: api.jujutsu.k42.com" http://192.232.4.7/uji-geto ; echo
```

![alt text](../assets/14-verifikasigeto.png)

Disini terlihat bahwa geto berhasil mengecurl worker pada api webnya.

Dengan itu, soal 14 sudah selesai.

## Soal 15

# Langkah-Langkah

## Penjelasan Awal
Pada soal ini, kita disuruh untuk mengkonfigurasikan Nginx pada geto sebagai Load Balancer internal dengan upstream api_cluster yang mengarahkan trafik ke nanami dan todo. Terapkan algoritma Weighted Round Robin dengan bobot 3:1, di mana nanami menerima porsi beban tiga kali lebih banyak daripada todo. Buktikan distribusi beban ini dengan melakukan loop request berulang kali ke geto dari jaringan lokal Data Center dan periksa rasio responnya.

### Geto
Jalankan script `soal15_geto.sh`.

![alt text](../assets/15-scriptgeto.png)

Disini terlihat bahwa script berhasil berjalan. 4 Request menjawab dengan OK dan upstream aktif berjalan.

### Verifikasi
Untuk melakukan verifikasi pembuktian distribusi 3:1, kita menjalankan berikut di node selain geto, misalnya yaga.

Di Yaga:
```
for i in $(seq 1 40); do
    curl -s http://192.232.4.2/lb/$i | sed -n 's/.*"worker":"\([^"]*\)".*/\1/p'
done | sort | uniq -c

# Lihat juga header yang menunjukkan worker penjawab:
curl -s -D - -o /dev/null http://192.232.4.2/ | grep -i x-upstream
```

![alt text](../assets/15-verifikasiyaga.png)
![alt text](../assets/15-verifikasiyaga2.png)

Disini terlihat bahwa rasio berhasil dimana nanami dan todo adalah 3:1 (nanaminanaminanamitodo).

Dan kita juga melakukan verifikasi di geto untuk bukti tambahan dari sisi geto dan worker (nanami, todo).

Di Geto:
```
awk '{print $3}' /var/log/nginx/lb_access.log | sort | uniq -c
```

![alt text](../assets/15-verifikasigeto.png)

Disini terlihat bahwa rasio benar 3:1 dan total adalah 40 (walaupun nanami 31, berarti total 41. Tetapi +1 ini berasal dari request lain ke geto maka tetap aman.) berserta source IP log worker.

Dengan itu, soal sudah selesai.

## Soal 16

# Langkah-Langkah

## Penjelasan Awal
Kita ditugaskan untuk mengkonfigurasikan Nginx pada gojo untuk melayani domain jujutsu.<xxxx>.com dan www.jujutsu.<xxxx>.com menggunakan metode Path-Based Routing. Atur agar request root (/) diteruskan secara Round Robin ke worker frontend (maki dan panda), sedangkan request ke path /api diteruskan langsung ke geto. Uji dari client Divisi A atau B bahwa akses ke web utama dibalas oleh Maki/Panda, sedangkan akses ke /api diteruskan dan dijawab oleh Nanami/Todo.

### Gojo
Jalankan script `script_gojo.sh` untuk nomor 16 dengan menjalankan:
```
./script_gojo.sh 16
```

![alt text](../assets/16-scriptgojo.png)

Disini terlihat bahwa script berhasil dijalankan dan kita bisa melihat direktif aktif dan pengujian lokal dari scriptnya yang terjalan dengan aman.

### Verifikasi
Kita melakukan verifikasi di node itadori dan ino.

Untuk melakukan verifikasi tersebut, kita jalankan script `soal16_itadori.sh` dan `soal16_ino.sh`

![alt text](../assets/16-scriptitadori.png)
![alt text](../assets/16-scriptino.png)

Disini terlihat bahwa verifikasi berhasil dimana pemanggilan akses web utama (/) dibalas oleh Maki/Panda, sedangkan akses ke /api diteruskan dan dijawab oleh Nanami/Todo sesuai dengan soal.

Dengan ini, soal 16 sudah selesai.

## Soal 17

# Langkah-Langkah

## Penjelasan Awal
Pada soal ini, kita perlu untuk mengkonfigurasikan gojo dan geto agar meneruskan informasi alamat klien melalui header X-Real-IP dan X-Forwarded-For. Pastikan geto hanya mempercayai informasi alamat klien yang diterima dari proxy terpercaya, dan skrip API menyimpan alamat klien yang telah diverifikasi ke kolom client_ip pada tabel request_logs di database yaga. Uji dengan mengirimkan request dari klien Network 2 dan Network 3 ke endpoint /api, kemudian periksa database untuk memastikan alamat yang tercatat sesuai dengan IP klien asal, bukan IP gojo atau geto.

### Geto
Jalankan script `script_geto.sh` untuk nomor 17 dengan menggunakan:
```
./script_geto.sh 17
```

![alt text](../assets/17-scriptgeto.png)

Disini terlihat script berjalan dengan aman dan sekarang menetapkan "trusted_proxy" sebagai 192.232.1.4 (gojo).

### Gojo
Jalankan script `script_gojo.sh` untuk nomor 17 dengan menggunakan:
```
./script_gojo.sh 17
```

![alt text](../assets/17-scriptgojo.png)

Disini terlihat script berjalan dengan aman dan menetapkan proxy_pass dengan alamat klien geto yang merupakan proxy terpercayanya.

### Woker API
Jalankan script `soal17_nanamitodokirara.sh` pada node nanami, todo, dan kirara.

![alt text](../assets/17-scriptnanami.png)
![alt text](../assets/17-scripttodo.png)
![alt text](../assets/17-scriptkirara.png)

Disini terlihat bahwa di setiap node worker api tersebut, "trusted_proxy" mengembalikan false, dikarenakan node tersebut bukan termasuk proxy yang terpercaya.

### Verifikasi
Untuk melakukan verifikasi, kita menjalankan script `soal17_itadoriino.sh` pada node itadori dan ino.

![alt text](../assets/17-scriptitadori.png)
![alt text](../assets/17-scriptino.png)

Disini terlihat bahwa verifikasi berhasil dikarenakan sudah sesuai dengan harapan, dimana client IP yang tercatat benar yaitu IP dari itadori dan ino (bukan gojo,geto).

Berikut kita perlu melakukan verifikasi di yaga untuk mengecek databasenya dengan script yang diberikan di akhir script itadori dan ino:
```
mariadb -e "SELECT id, client_ip, request_path, created_at
            FROM db_shibuya_K42.request_logs
            WHERE request_path LIKE '/api/uji-ip-%' ORDER BY id DESC LIMIT 20;"
```

![alt text](../assets/17-verifikasiyaga.png)

Disini verifikasi benar dikarenakan client_ip merupakan ip dari node itadori dan ino (node klien asal) dan bukan gojo atau geto, serta header palsu diabaikan (bukan 9.9.9.9).

Dan terakhir kita juga bisa memantau log dari geto tersendiri dengan menggunakan:
```
tail -5 /var/log/nginx/lb_access.log        # kolom real= berisi IP klien asal
```

![alt text](../assets/17-loggeto.png)

Disini terlihat bahwa di logsnya, kolom real berisi dengan ip klien asal (itadori dan ino).

Dengan ini, soal 17 selesai.

## Soal 18

# Langkah-Langkah

## Penjelasan Awal
Pada soal ini, nanami dan todo merupakan worker API utama, sedangkan kirara disiapkan sebagai worker cadangan. Kita ditugaskan untuk mengkonfigurasikan upstream api_cluster pada geto agar kirara menjadi server backup, serta terapkan passive health check dengan parameter max_fails=2 dan fail_timeout=5s pada worker API utama. Pastikan kirara menjalankan layanan API yang kompatibel dengan endpoint utama. Simulasikan gangguan dengan menghentikan layanan Nginx atau layanan API pada nanami dan todo. Buktikan dari klien bahwa request ke /api dialihkan ke kirara dan menghasilkan respons API yang valid tanpa error 502 Bad Gateway.

### Geto
Pertama kita perlu untuk mengkonfigurasi upstream api_cluster pada geto agar kirara menjadi server backup. Maka, kita jalankan script berikut
```
./script_geto 18
```

![alt text](../assets/18-scriptgeto.png)

Disini terlihat bahwa geto berhasil menambahkan ip kirara sebagai upstream api_cluster.

### Testing
Pertama, kita coba jalankan kondisi normal sebagai pembanding.

Misalnya, pada node itadori, kita jalankan script `soal18_itadori.sh` terlebih dahulu dengan:
```
./soal18_itadori.sh 40
```

Ini akan mensimulasikan itadori melakukan 40 request.

![alt text](../assets/18-scriptitadori.png)

Disini terlihat kondisi normal dimana 40 request dari itadori dapat berjalan dengan normal (sukses).

Setelah itu, mari kita coba jalankan simulasi gangguan dimana kita mematikan nginx di nanami dan todo dengan menjalankan script `soal18_nanamitodo` dengan melakukan:

```
./soal18_nanamitodo.sh stop nginx
```

Untuk mensimulasikan matinya nginx.

![alt text](../assets/18-simulasinanami.png)

![alt text](../assets/18-simulasitodo.png)

Setelah itu, kita menjalankan script pada itadori saat nginx pada nanami dan todo sedang mati.

![alt text](../assets/18-simulasiitadoringinx.png)

Disini terlihat bahwa sekarang semua request terkirim ke kirara daripada 30 ke nanami dan 10 ke todo (rasio 3:1). Ini membuktikan kirara berhasil menjadi worker cadangan.

Kita melakukan simulasi lanjut tetapi bedanya kita mematikan php pada nanami dan todo. (nginx hidup)

```
./soal18_nanamitodo.sh start nginx
./soal18_nanamitodo.sh stop php
```

![alt text](../assets/18-simulasinanamiphp.png
)

![alt text](../assets/18-simulasitodophp.png)

Setelah php mati, kita jalankan script lagi di itadori.

![alt text](../assets/18-simulasiitadoriphp.png)

Disini terlihat bahwa semua request terkirim ke kirara, yang berarti kirara berhasil lagi menjadi worker cadangan.

Terakhir kita melakukan pemulihan dengan menghidupkan lagi php pada nanami dan todo.
```
./soal18_nanamitodo.sh start php
```

![alt text](../assets/18-pemulihannanami.png)


![alt text](../assets/18-pemuilihantodo.png)

Setelah pemulihan, kita coba untuk terakhir kalinya di itadori.

![alt text](../assets/18-akhirsimulasi.png)

Disini terlihat bahwa request kembali terkirim ke nanami dan todo dengan rasio 3:1.

Dengan ini, soal 18 selesai.

## Soal 19

# Langkah-Langkah

## Penjelasan Awal
Pada nomor 19, gojo bertugas mengoptimalkan layanan web sekaligus membatasi request berlebihan.Kita bertugas untuk mengkonfigurasikan Nginx Proxy Caching untuk halaman web frontend dengan masa berlaku cache 10 menit dan tambahkan header X-Cache-Status. Terapkan rate limiting pada path /api dengan batas 10 request per detik per IP klien. Buktikan bahwa request ke halaman web yang memenuhi syarat cache menghasilkan status MISS pada akses awal dan HIT pada akses berikutnya. Uji rate limiting secara terpisah dengan mengirimkan request beruntun ke /api, kemudian catat status respons yang dihasilkan ketika batas terlampaui.

### Gojo
Pertama kita harus menjalankan konfigurasi gojo dengan menggunakan `script_gojo.sh`:
```
./script_gojo.sh 19
```

![alt text](../assets/19-scriptgojo.png)

Disini terlihat script berhasil berjalan dengan penambahan barisan yang mengandung #CACHE dan #RL (rate-limit).

### Pembuktian
Berikut kita melakukan pembuktian cache MISS lalu HIT pada node maki dan panda.

Di Maki dan Panda:
```
./soal19_makipanda.sh
```

![alt text](../assets/19-pembuktianmaki.png)
![alt text](../assets/19-pembuktianpanda.png)

Terlihat bahwa akses request ke halaman web berhasil memenuhi syarat cache menghasilkan status MISS pada akses awal dan HIT pada akses berikutnya.

Berikut kita juga perlu melakukan pembuktian pada rate limitingnya. Kita gunakan node yang random untuk melakukan pembuktiannya, misalnya node maki lagi.

Di Maki:
```
./soal19_maki2.sh 40
```

![alt text](../assets/19-pembuktianrl.png)

Disini terlihat bahwa kelebihan request berhasil ditolak dengan status 429 dimana ada 6 request yang diterima (status 200) dan 34 status yang tidak diterima (status 429). Ini berhasil membuktikan rate limiting ke path /api dengan batas 10 request per detik per IP klien.

Dan terakhir, kita perlu mengecek log di gojo dengan menggunakan line yang diberikan setelah script dijalankan, yaitu:
```
grep 'limit=REJECTED' /var/log/nginx/gojo_access.log | tail -10
```

![alt text](../assets/19-loggojo.png)

Disini terlihat baris yang ditolak memuat status=429, limit=REJECTED, dan up="-" karena request tidak pernah diteruskan ke geto.

Dengan ini, soal 19 selesai.

## Soal 20

# Langkah-Langkah

## Penjelasan Awal
Kita ditugaskan untuk melakukan bechmarking dari terminal kusakabe, jalankan benchmark menggunakan Apache Benchmark dengan parameter -n 600 -c 30 menuju http://jujutsu.k42.com/. Catat Requests per Second (RPS), latensi, dan jumlah request yang gagal. Lakukan pengujian tambahan pada endpoint /api untuk mengamati efek rate limiting. Bandingkan hasil pengujian baseline dengan hasil ketika rate limiting aktif, serta gunakan access log gojo untuk membedakan kegagalan aplikasi, koneksi, dan request yang ditolak oleh kebijakan rate limit.

### Pendahuluan
Pertama, di kusakabe (Alpine), kita perlu untuk memasang ab dan pastikan domain ter-resolve:
```
apk add --no-cache apache2-utils
ab -V | head -1
ping -c 1 jujutsu.k42.com
```

![alt text](../assets/20-pasangkusakabe.png)

Sekarang Kusakabe siap untuk mulai dikerjakan, maka kita langsung saja masuk.

### Gojo
Kita pertama membuat access log pada gojo untuk membedakan kegagalan aplikasi, koneksi, dan request yang ditolak oleh kebijakan rate limit.

Pertama, kita memberi penanda log pada Gojo sebelum memulai benchmarking:
```
./soal20_gojo.sh mark
```

![alt text](../assets/20-gojomark.png)

Mark sudah dibuat, sekarang kita masuk ke kusakabe.

### Benchmarking A
Lalu kita jalankan `soal20_kusakabe.sh` dengan:

Di Kusakabe:
```
./soal20_kusakabe web baseline
```

![alt text](../assets/20-baselinekusakabe.png)

Script berhasil berjalan, berikut kita perlu untuk lanjut di gojo.

Di Gojo:
```
./soal20_gojo.sh summary
```

![alt text](../assets/20-summarygojo.png)

Disini terlihat bahwa ringkasan log gojo berhasil terlihat hasil dari ./soal20_kusakabe web baseline yang tercatat ke dalam summarynya.

### Benchmarking B
Sekarang kita lakukan benchmarking tanpa rate limiting pada baseline.

Di Gojo, kita jalankan berikut untuk mematikan rate-limiting dan membuat mark baru:
```
RATE_LIMIT=off ./script_gojo.sh 19
./soal20_gojo.sh mark
```

![alt text](../assets/20-gojorloff.png)

Disini terlihat rate-limiting berhasil dimatikan dan berhasil terbuatnya mark baru.

Di Kusakabe:
```
./soal20_kusakabe.sh api tanpa-limit
```

Jalankan berikut untuk menjalankan script api tanpa limitnya.

![alt text](../assets/20-kusakabenorl.png)

Script berhasil berjalan, lalu kita pantau summary dari gojo.
```
./soal20_gojo.sh summary
```

![alt text](../assets/20-summarygojonorl.png)

Disini terlihat bahwa tanpa rate-limiting, semua request berhasil diterima dengan waktu yang pendek.

### Benchmarking C
Sekarang kita lakukan benchmarking dengan rate limiting.

Di Gojo:
```
./script_gojo.sh 19
./soal20_gojo.sh mark
```

![alt text](../assets/20-gojorlon.png)

Disini terlihat rate-limiting sekarang hidup, lanjut.

Di Kusakabe:
```
./soal20_kusakabe.sh api dengan-limit
```

![alt text](../assets/20-kusakabewithrl.png)

Dan terakhir kita pantau summary dari gojo lagi.
```
./soal20_gojo.sh summary
```

![alt text](../assets/20-summarygojowithrl.png)

Disini terlihat bahwa dari 600 request yang dikirim, hanya 7 saja yang diterima dikarenakan rate-limiting.

### Perbandingan Hasil
Untuk membandingkan semua hasilnya, kita jalankan berikut.

Di Kusakabe:
```
./soal20_kusakabe.sh summary
```

![alt text](../assets/20-summarybenchmarking.png)

Sekarang kita bisa melihat hasil summary keseluruhan dari semuanya, mulai dari web-baseline, api-tanpa-limit, dan api-dengan-limit.

Berdasarkan hasil benchmarking, web baseline mampu menangani 600 request dengan RPS 1.611,40 tanpa request gagal. Pada endpoint API, kondisi tanpa rate limiting menghasilkan RPS 699,91 dengan latensi rata-rata 42,863 ms dan 150 request gagal, sedangkan saat rate limiting aktif, RPS meningkat menjadi 5.397,92 dengan latensi rata-rata 5,558 ms, tetapi terdapat 598 failed requests dan 593 respons non-2xx. Hal ini menunjukkan bahwa rate limiting membatasi banyaknya request yang diproses dan membuat respons terhadap request yang diterima lebih cepat, tetapi angka RPS yang tinggi tidak berarti seluruh request berhasil. Hasil ini perlu dianalisis bersama access log Gojo untuk memastikan apakah request gagal tersebut memang ditolak dengan HTTP 429 atau disebabkan oleh faktor lain.

Dengan ini, soal 20 selesai.
