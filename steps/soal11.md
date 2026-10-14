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
![alt text](/assets/11-pendahuluanutahime.png)
![alt text](/assets/11-pendahuluanshoko.png)

Setelah aman, maka mari kita mulai pengerjaannya.

### Utahime
Jalankan script `soal11_utahime.sh` terlebih dahulu. Jika sudah dijalankan dan benar, akan menghasilkan berikut:
![alt text](/assets/11-utahimeberhasil.png)

### Shoko
Jalankan script `soal11_shoko.sh` untuk menjalankan setup slave dan juga sekaligus melakukan transfer zona dan mengecek apakah slave berhasil mengambil dari master. Hasilnya seperti berikut:
![alt text](/assets/11-shokoberhasil.png)

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

![alt text](/assets/11-utahimenaikserial.png)
![alt text](/assets/11-shokonaikserial.png)

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

![alt text](/assets/11-queryitadori.png)

Disini terlihat bahwa di node itadori ia berhasil melakukan dig dan menampilkan nama zonanya yaitu jujutsu.k42.com serta nomor serial dari zona tersebut.

Dengan ini, soal 11 selesai.