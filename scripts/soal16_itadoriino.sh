#!/bin/sh
# Nomor 16 - Uji Path-Based Routing dari client Divisi A atau B
# Pemakaian: sh /root/test-routing.sh [jumlah_request]
# Jika DNS belum bisa resolve:  GOJO_IP=192.232.1.4 sh /root/test-routing.sh
HOST="${HOST:-jujutsu.k42.com}"
N="${1:-8}"
STAMP=$(date +%H%M%S)
RES=""
[ -n "$GOJO_IP" ] && RES="--resolve $HOST:80:$GOJO_IP --resolve www.$HOST:80:$GOJO_IP"

if ! command -v curl >/dev/null 2>&1; then
    apk add --no-cache curl >/dev/null 2>&1 \
      || { apt-get update >/dev/null 2>&1; apt-get install -y curl >/dev/null 2>&1; }
fi

MYIP=$(ip -4 -o addr show dev eth0 | awk '{print $4}' | cut -d/ -f1)
echo "Penguji: $(hostname) ($MYIP)"
TMPW=$(mktemp); TMPA=$(mktemp)

echo
echo "== 1. Web utama http://$HOST/  (harus dijawab maki dan panda bergantian) =="
i=1
while [ "$i" -le "$N" ]; do
    curl -s -m 5 $RES "http://$HOST/?rr=$STAMP-$i" | sed 's/<[^>]*>/ /g' | tr -s ' \n' ' ' \
        | grep -o 'Hostname: [a-z]*' | awk '{print $2}' >> "$TMPW"
    i=$((i+1))
done
echo "urutan : $(tr '\n' ' ' < "$TMPW")"
sort "$TMPW" | uniq -c

echo
echo "== 2. API http://$HOST/api  (harus dijawab nanami dan todo) =="
i=1
while [ "$i" -le "$N" ]; do
    out=$(curl -s -m 5 $RES "http://$HOST/api/uji-routing-$STAMP/$i")
    echo "$out" | sed -n 's/.*"worker":"\([^"]*\)".*/\1/p' >> "$TMPA"
    i=$((i+1))
    sleep 0.12 2>/dev/null
done
echo "urutan : $(tr '\n' ' ' < "$TMPA")"
sort "$TMPA" | uniq -c

echo
echo "== 3. Domain www =="
curl -s -m 5 $RES "http://www.$HOST/" | sed 's/<[^>]*>/ /g' | tr -s ' \n' ' ' | cut -c1-120; echo

rm -f "$TMPW" "$TMPA"