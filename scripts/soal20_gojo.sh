#!/bin/bash
# Nomor 20 - Ringkasan access log gojo untuk membedakan jenis kegagalan
# Pemakaian (di gojo):
#   bash /root/gojo-log-summary.sh mark       -> tandai posisi log SEBELUM benchmark
#   bash /root/gojo-log-summary.sh summary    -> ringkas log SEJAK penanda
LOG=/var/log/nginx/gojo_access.log
MARK=/root/.gojo_log_mark

case "${1:-summary}" in
    mark)
        wc -l < "$LOG" > "$MARK"
        echo "Penanda disimpan di baris $(cat "$MARK") dari $LOG"
        ;;
    summary)
        START=$(cat "$MARK" 2>/dev/null || echo 0)
        SEG=$(mktemp)
        tail -n +$((START + 1)) "$LOG" > "$SEG"
        TOTAL=$(wc -l < "$SEG")
        API=$(grep -c 'req="[A-Z]* /api' "$SEG")
        WEB=$((TOTAL - API))

        OK=$(grep -c ' status=2' "$SEG")
        RL=$(grep -c 'limit=REJECTED' "$SEG")
        APP=$(grep -c ' status=500 ' "$SEG")
        GW=$(grep -cE ' status=(502|503|504) ' "$SEG")
        CLI=$(grep -c ' status=499 ' "$SEG")
        OTHER=$((TOTAL - OK - RL - APP - GW - CLI))

        echo "=== Ringkasan access log gojo (sejak baris $START) ==="
        echo "Total request di log : $TOTAL   (web / : $WEB | api /api : $API)"
        echo
        echo "--- Klasifikasi ---"
        printf '%-46s %6s\n' "Sukses (2xx)" "$OK"
        printf '%-46s %6s\n' "Ditolak kebijakan rate limit (429, limit=REJECTED)" "$RL"
        printf '%-46s %6s\n' "Kegagalan aplikasi (500 dari API/worker)" "$APP"
        printf '%-46s %6s\n' "Kegagalan koneksi/gateway (502/503/504)" "$GW"
        printf '%-46s %6s\n' "Klien memutus koneksi (499)" "$CLI"
        printf '%-46s %6s\n' "Lainnya" "$OTHER"
        echo
        echo "--- Rincian status HTTP ---"
        grep -o ' status=[0-9]*' "$SEG" | sort | uniq -c
        echo
        echo "--- Cache (halaman web) ---"
        grep -o 'cache=[A-Z-]*' "$SEG" | sort | uniq -c
        echo
        echo "--- Waktu respons gojo (request_time) rata-rata per kelompok ---"
        awk '
        {
            st = ""; rt = ""
            if (match($0, / status=[0-9]+/)) st = substr($0, RSTART + 8, RLENGTH - 8)
            if (match($0, / rt=[0-9.]+/))    rt = substr($0, RSTART + 4, RLENGTH - 4)
            if (st == "" || rt == "") next
            if (st ~ /^2/)       g = "2xx sukses"
            else if (st == "429") g = "429 ditolak rate limit"
            else if (st ~ /^5/)   g = "5xx error"
            else                  g = "lainnya"
            sum[g] += rt; cnt[g]++
        }
        END {
            for (g in cnt) printf "%-26s n=%-6d rata-rata=%.1f ms\n", g, cnt[g], sum[g] / cnt[g] * 1000
        }' "$SEG"
        echo
        echo "--- 5 contoh baris ditolak rate limit ---"
        grep 'limit=REJECTED' "$SEG" | tail -5
        rm -f "$SEG"
        ;;
    *)
        echo "Pemakaian: bash $0 <mark|summary>"
        exit 1
        ;;
esac