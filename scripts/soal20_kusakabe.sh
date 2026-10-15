#!/bin/sh
# Nomor 20 - Benchmark Apache Benchmark dari kusakabe (ab -n 600 -c 30)
# Pemakaian:
#   sh /root/kusakabe-benchmark.sh web <label>    -> http://jujutsu.k42.com/
#   sh /root/kusakabe-benchmark.sh api <label>    -> http://jujutsu.k42.com/api
#   sh /root/kusakabe-benchmark.sh summary        -> tabel perbandingan semua hasil
# Hasil mentah disimpan di /root/ab-<target>-<label>.txt
HOST="${HOST:-jujutsu.k42.com}"
N="${N:-600}"
C="${C:-30}"
MODE="$1"
LABEL="${2:-run}"

if ! command -v ab >/dev/null 2>&1; then
    apk add --no-cache apache2-utils >/dev/null 2>&1 \
      || { apt-get update >/dev/null 2>&1; apt-get install -y apache2-utils >/dev/null 2>&1; }
fi

metrik() {
    f="$1"
    RPS=$(grep 'Requests per second' "$f" | awk '{print $4}')
    TPR=$(grep 'Time per request' "$f" | head -1 | awk '{print $4}')
    TPA=$(grep 'Time per request' "$f" | tail -1 | awk '{print $4}')
    COMP=$(grep 'Complete requests' "$f" | awk '{print $3}')
    FAIL=$(grep '^Failed requests' "$f" | awk '{print $3}')
    N2=$(grep 'Non-2xx' "$f" | awk '{print $3}'); N2="${N2:-0}"
    P50=$(grep '^ *50%' "$f" | awk '{print $2}')
    P95=$(grep '^ *95%' "$f" | awk '{print $2}')
    P99=$(grep '^ *99%' "$f" | awk '{print $2}')
    PMAX=$(grep '100%' "$f" | awk '{print $2}')
    DET=$(grep '(Connect:' "$f" | sed 's/^ *//')
}

case "$MODE" in
    web|api)
        if [ "$MODE" = "web" ]; then URL="http://$HOST/"; else URL="http://$HOST/api"; fi
        OUT="/root/ab-$MODE-$LABEL.txt"
        echo "Penguji : $(hostname)"
        echo "Perintah: ab -n $N -c $C $URL"
        ab -n "$N" -c "$C" "$URL" > "$OUT" 2>&1
        metrik "$OUT"
        echo
        echo "=== Ringkasan ($MODE / $LABEL) ==="
        echo "Requests per second (RPS)      : $RPS"
        echo "Latensi rata-rata per request  : $TPR ms (mean) | $TPA ms (across all concurrent requests)"
        echo "Latensi persentil (ms)         : p50=$P50  p95=$P95  p99=$P99  maks=$PMAX"
        echo "Complete requests              : $COMP"
        echo "Failed requests                : $FAIL   $DET"
        echo "Non-2xx responses              : $N2"
        echo
        echo "Hasil lengkap: $OUT"
        echo "Lanjut di gojo: bash /root/gojo-log-summary.sh summary"
        ;;
    summary)
        printf '%-22s %9s %10s %7s %7s %7s %7s %8s\n' HASIL RPS 'mean(ms)' p95 p99 FAILED NON2XX COMPLETE
        for f in /root/ab-*.txt; do
            [ -f "$f" ] || continue
            metrik "$f"
            nm=$(basename "$f" .txt | sed 's/^ab-//')
            printf '%-22s %9s %10s %7s %7s %7s %7s %8s\n' "$nm" "$RPS" "$TPR" "$P95" "$P99" "$FAIL" "$N2" "$COMP"
        done
        ;;
    *)
        echo "Pemakaian: sh $0 <web|api> <label>  atau  sh $0 summary"
        exit 1
        ;;
esac