#!/bin/bash
# Nomor 18 - Simulasi gangguan pada worker API (nanami, todo)
# Pemakaian:  bash /root/worker-toggle.sh <stop|start|status> [nginx|php]
#   nginx = layanan web Nginx (default)
#   php   = layanan API (PHP-FPM)
ACTION="${1:-status}"
WHAT="${2:-nginx}"
PHPV=$(ls /etc/php 2>/dev/null | sort -V | tail -1)

case "$WHAT" in
    nginx) SVC="nginx";            PROC="nginx" ;;
    php)   SVC="php${PHPV}-fpm";   PROC="php-fpm" ;;
    *)     echo "Pemakaian: bash $0 <stop|start|status> [nginx|php]"; exit 1 ;;
esac

case "$ACTION" in
    stop|start|restart) service "$SVC" "$ACTION" ;;
    status) ;;
    *) echo "Pemakaian: bash $0 <stop|start|status> [nginx|php]"; exit 1 ;;
esac
sleep 1

if pgrep -f "$PROC" >/dev/null 2>&1; then
    echo "[$(hostname)] $SVC: BERJALAN"
else
    echo "[$(hostname)] $SVC: MATI"
fi