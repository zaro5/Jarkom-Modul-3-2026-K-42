# Langkah-Langkah

## Arahan

### tengen

Masukkan alamat MAC ke `/etc/dhcp/dhcpd.conf` dari masing-masing node di Network 2, yakni `itadori`, `fushiguro`, `zenin`, dan `okkotsu`. 

```bash
ip a
```

Gunakan perintah di atas untuk melakukan pengecekan MAC di masing-masing node.

Dari perintah tersebut, didapat alamat MAC sebagai berikut:

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

### jichi

Pada node `jichi`, pastikan dhcp sudah running dengan tanda ACTIVE.

## Set Up

Untuk menjalankan soal 4, jalankan script pada masing-masing node. 

- `soal04_jichi.sh` pada `jichi`
- `soal04_tengen.sh` pada `tengen`

## Hasil

