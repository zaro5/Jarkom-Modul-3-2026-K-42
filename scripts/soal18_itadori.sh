#!/bin/sh
# Nomor 18 - Distribusi respons /api dari klien (lewat gojo) beserta status HTTP
# Pemakaian: sh /root/test-failover.sh [jumlah_request]
# Jika DNS belum bisa resolve:  GOJO_IP=192.232.1.4 sh /root/test-failover.sh
HOST="${HOST:-jujutsu.k42.com}"
N="${1:-40}"
STAMP=$(date +%H%M%S)
RES=""
[ -n "$GOJO_IP" ] && RES="--resolve $HOST:80:$GOJO_IP"

if ! command -v curl >/dev/null 2>&1; then
    apk add --no-cache curl >/dev/null 2>&1 \
      || { apt-get update >/dev/null 2>&1; apt-get install -y curl >/dev/null 2>&1; }
fi

TMP=$(mktemp)
echo "Penguji: $(hostname) | $N request ke http://$HOST/api (tag fo-$STAMP)"

i=1
while [ "$i" -le "$N" ]; do
    out=$(curl -s -m 10 $RES -w '\n%{http_code}' "http://$HOST/api/fo-$STAMP/$i")
    code=$(echo "$out" | tail -n 1)
    w=$(echo "$out" | sed -n 's/.*"worker":"\([^"]*\)".*/\1/p')
    [ -z "$w" ] && w="-"
    echo "$code $w" >> "$TMP"
    i=$((i+1))
    sleep 0.12 2>/dev/null
done

echo
echo "--- Jumlah per (HTTP status, worker) ---"
sort "$TMP" | uniq -c

OK=$(grep -c '^200 ' "$TMP")
E502=$(grep -c '^502 ' "$TMP")
ERR=$(grep -vc '^200 ' "$TMP")
echo
echo "sukses (200) = $OK | 502 Bad Gateway = $E502 | total non-200 = $ERR"
if [ "$ERR" -eq 0 ]; then
    echo "HASIL: semua request dijawab dengan respons API valid (tanpa 502)"
else
    echo "HASIL: ada request gagal, cek log geto: tail -20 /var/log/nginx/lb_access.log"
fi
rm -f "$TMP"