# Langkah-Langkah

## Penjelasan Awal

### Jinchi

Pada node `jichi`, pastikan dhcp sudah berjalan dengan status `Active: active (running)`

```bash
systemctl restart isc-dhcp-relay
systemctl enable isc-dhcp-relay
systemctl status isc-dhcp-relay
```

### Tengen

Pada node `tengen`, masukkan alamat MAC dari semua node Network 3 (kecuali Kugisaki). Dengan `ino` dan `kusakabe` diberikan *short lease* dan `miwa` diberikan *long lease*.

- ino

```bash
02:42:5b:aa:33:00
```

- kusakabe

```bash
02:42:30:59:6b:00
```

- miwa

```bash
02:42:8e:c4:83:00
```

## Set Up

Untuk menjalankan soal 5, jalankan script pada node `tengen` saja.

- `soal05_tengen.sh` pada `tengen`

## Hasil

