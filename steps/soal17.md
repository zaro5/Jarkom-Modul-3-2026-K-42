# Langkah-Langkah

## Penjelasan Awal
Pada soal ini, kita perlu untuk mengkonfigurasikan gojo dan geto agar meneruskan informasi alamat klien melalui header X-Real-IP dan X-Forwarded-For. Pastikan geto hanya mempercayai informasi alamat klien yang diterima dari proxy terpercaya, dan skrip API menyimpan alamat klien yang telah diverifikasi ke kolom client_ip pada tabel request_logs di database yaga. Uji dengan mengirimkan request dari klien Network 2 dan Network 3 ke endpoint /api, kemudian periksa database untuk memastikan alamat yang tercatat sesuai dengan IP klien asal, bukan IP gojo atau geto.

### Geto
Jalankan script `script_geto.sh` untuk nomor 17 dengan menggunakan:
```
./script_geto.sh 17
```

![alt text](/assets/17-scriptgeto.png)

Disini terlihat script berjalan dengan aman dan sekarang menetapkan "trusted_proxy" sebagai 192.232.1.4 (gojo).

### Gojo
Jalankan script `script_gojo.sh` untuk nomor 17 dengan menggunakan:
```
./script_gojo.sh 17
```

![alt text](/assets/17-scriptgojo.png)

Disini terlihat script berjalan dengan aman dan menetapkan proxy_pass dengan alamat klien geto yang merupakan proxy terpercayanya.

### Woker API
Jalankan script `soal17_nanamitodokirara.sh` pada node nanami, todo, dan kirara.

![alt text](/assets/17-scriptnanami.png)
![alt text](/assets/17-scripttodo.png)
![alt text](/assets/17-scriptkirara.png)

Disini terlihat bahwa di setiap node worker api tersebut, "trusted_proxy" mengembalikan false, dikarenakan node tersebut bukan termasuk proxy yang terpercaya.

### Verifikasi
Untuk melakukan verifikasi, kita menjalankan script `soal17_itadoriino.sh` pada node itadori dan ino.

![alt text](/assets/17-scriptitadori.png)
![alt text](/assets/17-scriptino.png)

Disini terlihat bahwa verifikasi berhasil dikarenakan sudah sesuai dengan harapan, dimana client IP yang tercatat benar yaitu IP dari itadori dan ino (bukan gojo,geto).

Berikut kita perlu melakukan verifikasi di yaga untuk mengecek databasenya dengan script yang diberikan di akhir script itadori dan ino:
```
mariadb -e "SELECT id, client_ip, request_path, created_at
            FROM db_shibuya_K42.request_logs
            WHERE request_path LIKE '/api/uji-ip-%' ORDER BY id DESC LIMIT 20;"
```

![alt text](/assets/17-verifikasiyaga.png)

Disini verifikasi benar dikarenakan client_ip merupakan ip dari node itadori dan ino (node klien asal) dan bukan gojo atau geto, serta header palsu diabaikan (bukan 9.9.9.9).

Dan terakhir kita juga bisa memantau log dari geto tersendiri dengan menggunakan:
```
tail -5 /var/log/nginx/lb_access.log        # kolom real= berisi IP klien asal
```

![alt text](/assets/17-loggeto.png)

Disini terlihat bahwa di logsnya, kolom real berisi dengan ip klien asal (itadori dan ino).

Dengan ini, soal 17 selesai.