
#!/bin/sh
# Pengujian proxy cache Gojo - Nomor 19

HOST="${HOST:-jujutsu.k42.com}"
GOJO_IP="${GOJO_IP:-192.232.1.4}"
STAMP="$(date +%Y%m%d%H%M%S)"
RESOLVE="--resolve ${HOST}:80:${GOJO_IP}"

if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl belum terpasang"
    exit 1
fi

H=$(mktemp)
B=$(mktemp)
trap 'rm -f "$H" "$B"' EXIT

akses() {
    URL="$1"
    LABEL="$2"

    CODE=$(curl -sS --connect-timeout 5 --max-time 15 \
        $RESOLVE -D "$H" -o "$B" \
        -w '%{http_code}' "$URL") || {
        echo "$LABEL: CURL GAGAL"
        return 1
    }

    CACHE=$(grep -i '^X-Cache-Status:' "$H" |
        tail -n 1 | cut -d ':' -f 2 | tr -d '\r ')

    WORKER=$(sed 's/<[^>]*>/ /g' "$B" |
        tr '\n' ' ' |
        grep -oiE 'Hostname:[[:space:]]*[[:alnum:]_-]+' |
        head -n 1)

    echo "$LABEL: HTTP=$CODE X-Cache-Status=${CACHE:-TIDAK_ADA_HEADER} ${WORKER:-}"

    if [ -z "$CACHE" ]; then
        echo "--- Header respons ---"
        tr -d '\r' < "$H" |
            grep -iE '^(HTTP/|Server:|Location:|X-Cache-Status:|Content-Type:)' || true
        echo "--- Awal body ---"
        head -c 250 "$B"
        echo
    fi
}

echo "Penguji: $(hostname)"
echo "Target : $HOST -> $GOJO_IP"
echo

echo "=== URL sama: diharapkan MISS lalu HIT ==="
URL="http://${HOST}/?cache-test=${STAMP}"
akses "$URL" "akses 1" || exit 1
akses "$URL" "akses 2" || exit 1
akses "$URL" "akses 3" || exit 1
akses "$URL" "akses 4" || exit 1

echo
echo "=== URL baru: masing-masing diharapkan MISS ==="
akses "http://${HOST}/?cache-test=${STAMP}-b" "halaman B" || exit 1
akses "http://${HOST}/?cache-test=${STAMP}-c" "halaman C" || exit 1