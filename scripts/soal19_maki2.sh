
#!/bin/sh
# Nomor 19 - Uji rate limiting /api pada Gojo
# Pemakaian: sh /root/soal19_maki2.sh [jumlah_request]

HOST="${HOST:-jujutsu.k42.com}"
GOJO_IP="${GOJO_IP:-192.232.1.4}"
N="${1:-40}"
STAMP="$(date +%H%M%S)"
BASE_URL="http://${HOST}"
TMP="$(mktemp -d)" || exit 1

trap 'rm -rf "$TMP"' EXIT HUP INT TERM

if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl belum terpasang"
    exit 1
fi

echo "Penguji: $(hostname)"
echo "Target : ${HOST} -> ${GOJO_IP}"
echo "Jumlah : ${N} request"
echo

# Tes koneksi awal agar masalah jaringan terlihat sebelum tes serentak.
echo "=== Pemeriksaan koneksi ke Gojo ==="
curl -sS --connect-timeout 5 --max-time 10 \
    --resolve "${HOST}:80:${GOJO_IP}" \
    -o /dev/null -w 'HTTP %{http_code}\n' \
    "${BASE_URL}/api/preflight"

if [ "$?" -ne 0 ]; then
    echo "ERROR: Tidak berhasil terhubung ke Gojo."
    echo "Periksa IP, routing, dan service Nginx."
    exit 1
fi

echo
echo "=== Mengirim ${N} request serentak ke /api ==="

i=1
while [ "$i" -le "$N" ]; do
    (
        curl -sS --connect-timeout 5 --max-time 15 \
            --resolve "${HOST}:80:${GOJO_IP}" \
            -o /dev/null -w '%{http_code}\n' \
            "${BASE_URL}/api/rl-${STAMP}/${i}" \
            > "$TMP/status.$i" 2> "$TMP/error.$i"
    ) &
    i=$((i + 1))
done

wait

cat "$TMP"/status.* 2>/dev/null | sort | uniq -c

OK=$(grep -h -c '^200$' "$TMP"/status.* 2>/dev/null |
    awk '{s += $1} END {print s+0}')
LIM=$(grep -h -c '^429$' "$TMP"/status.* 2>/dev/null |
    awk '{s += $1} END {print s+0}')
BAD=$(grep -h -c '^000$' "$TMP"/status.* 2>/dev/null |
    awk '{s += $1} END {print s+0}')

echo
echo "HTTP 200 = $OK"
echo "HTTP 429 = $LIM"
echo "HTTP 000 = $BAD"

if [ "$BAD" -gt 0 ]; then
    echo
    echo "=== Contoh error curl ==="
    grep -h . "$TMP"/error.* 2>/dev/null | head -10
fi

echo
if [ "$LIM" -gt 0 ]; then
    echo "HASIL: Ada request yang ditolak dengan HTTP 429."
elif [ "$BAD" -gt 0 ]; then
    echo "HASIL: Sebagian request gagal di tingkat koneksi."
else
    echo "HASIL: Belum ada HTTP 429; periksa konfigurasi rate limiting Gojo."
fi

echo
echo "Periksa log Gojo:"
echo "grep 'limit=REJECTED' /var/log/nginx/gojo_access.log | tail -10"