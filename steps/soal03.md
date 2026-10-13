# Langkah-langkah

## Arahan

### tengen

Pada node `tengen`, masuk ke `/etc/network/interfaces` dan ubah address nya menjadi `192.232.4.10`. Pastikan gateawaynya masih `192.232.4.1`.

Setelahnya, restart ulang dhcp. Pastikan server running.

```bash
systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server
systemctl status isc-dhcp-server
```

### jichi

Ubah isi `/etc/default/isc/dhcp/relay` di bagian SERVERS menjadi `SERVERS="192.232.4.10".

## Set Up

Untuk menjalankan nomor 3, jalankan script yang telah dibuat.

- `soal03_jichi.sh` pada node `jichi`
