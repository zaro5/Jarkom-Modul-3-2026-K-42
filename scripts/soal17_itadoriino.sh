#!/bin/sh
# Nomor 17 - Uji pencatatan IP klien asli
# Mode default : lewat gojo     ->  sh /root/test-clientip.sh        (jalankan di client Network 2 dan Network 3)
# Mode direct  : langsung geto  ->  sh /root/test-clientip.sh direct (jalankan di node Data Center, mis. yaga)
HOST="${HOST:-jujutsu.k42.com}"
MODE="${1:-gojo}"
STAMP=$(date +%H%M%S)
RES=""
[ -n "$GOJO_IP" ] && RES="--resolve $HOST:80:$GOJO_IP"

if ! command -v curl >/dev/null 2>&1; then
    apk add --no-cache curl >/dev/null 2>&1 \
      || { apt-get update >/dev/null 2>&1; apt-get install -y curl >/dev/null 2>&1; }
fi

MYIP=$(ip -4 -o addr show dev eth0 | awk '{print $4}' | cut -d/ -f1)
TAG="uji-ip-$(hostname)-$STAMP"
if [ "$MODE" = "direct" ]; then BASE="http://192.232.4.2"; else BASE="http://$HOST"; fi

echo "Penguji   : $(hostname)  IP asli = $MYIP"
echo "Jalur     : $MODE ($BASE)"
printf '%-34s %-16s %-16s %s\n' REQUEST CLIENT_IP_TERCATAT PEER HASIL

cek() {
    # $1 = label, sisanya = argumen curl tambahan
    label="$1"; shift
    out=$(curl -s -m 5 $RES "$@")
    cip=$(echo "$out" | sed -n 's/.*"client_ip":"\([^"]*\)".*/\1/p')
    peer=$(echo "$out" | sed -n 's/.*"peer":"\([^"]*\)".*/\1/p')
    [ "$cip" = "$MYIP" ] && st=OK || st=GAGAL
    printf '%-34s %-16s %-16s %s\n' "$label" "${cip:--}" "${peer:--}" "$st"
}

cek "normal #1"  "$BASE/api/$TAG/1"
sleep 0.12 2>/dev/null
cek "normal #2"  "$BASE/api/$TAG/2"
sleep 0.12 2>/dev/null
cek "header palsu (9.9.9.9)" -H "X-Real-IP: 9.9.9.9" -H "X-Forwarded-For: 9.9.9.9" "$BASE/api/$TAG/spoof"

echo
echo "Harapan: CLIENT_IP_TERCATAT = $MYIP di semua baris (bukan IP gojo 192.232.1.4 atau geto 192.232.4.2,"
echo "         dan header palsu diabaikan)."
echo "Cek database di yaga:"
echo "  mariadb -e \"SELECT id, client_ip, request_path FROM db_shibuya_K42.request_logs WHERE request_path LIKE '/api/$TAG%';\""