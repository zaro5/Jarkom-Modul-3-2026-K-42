#!/bin/bash
# Nomor 13 - MariaDB Slave (inumaki)
# Jalankan di inumaki SETELAH yaga-master.sh selesai:  bash /root/inumaki-slave.sh
set -e

YAGA_IP="${YAGA_IP:-192.232.4.9}"
DB_NAME="${DB_NAME:-db_shibuya_K42}"
REPL_USER="${REPL_USER:-repl}"
REPL_PASS="${REPL_PASS:-replpass}"

is_running() { pgrep -x mariadbd >/dev/null || pgrep -x mysqld >/dev/null; }

start_mariadb() {
    if ! is_running; then
        service mariadb start >/dev/null 2>&1 \
          || service mysql start >/dev/null 2>&1 \
          || (nohup mysqld_safe --user=mysql >/var/log/mysql/mysqld_safe.out 2>&1 &)
    fi
    for i in $(seq 1 30); do
        mariadb-admin ping --silent 2>/dev/null && return 0
        sleep 1
    done
    echo "ERROR: MariaDB gagal start"; exit 1
}

stop_mariadb() {
    if is_running; then
        mariadb-admin shutdown 2>/dev/null || service mariadb stop >/dev/null 2>&1 || true
        for i in $(seq 1 20); do is_running || break; sleep 1; done
    fi
}

# 1. Instalasi
export DEBIAN_FRONTEND=noninteractive
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update
apt-get install -y mariadb-server mariadb-client

mkdir -p /run/mysqld /var/log/mysql
chown mysql:mysql /run/mysqld /var/log/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# 2. Konfigurasi Slave: server-id harus beda dari Master
cat > /etc/mysql/mariadb.conf.d/99-replication.cnf << CNF
[mysqld]
bind-address     = 0.0.0.0
skip-name-resolve
server-id        = 2
read_only        = 1
CNF

stop_mariadb
start_mariadb

# 3. Hubungkan ke Master (GTID: mulai dari awal binary log Master)
mariadb << SQL
STOP SLAVE;
CHANGE MASTER TO
    MASTER_HOST='${YAGA_IP}',
    MASTER_PORT=3306,
    MASTER_USER='${REPL_USER}',
    MASTER_PASSWORD='${REPL_PASS}',
    MASTER_USE_GTID=slave_pos,
    MASTER_CONNECT_RETRY=10;
START SLAVE;
SQL

# 4. Tunggu koneksi dan sinkronisasi awal (maks 20 detik)
for i in $(seq 1 20); do
    IO=$(mariadb -e "SHOW SLAVE STATUS\G" | awk '/Slave_IO_Running:/ {print $2}')
    SQLR=$(mariadb -e "SHOW SLAVE STATUS\G" | awk '/Slave_SQL_Running:/ {print $2}')
    [ "$IO" = "Yes" ] && [ "$SQLR" = "Yes" ] && break
    sleep 1
done

echo "=== Status replikasi ==="
mariadb -e "SHOW SLAVE STATUS\G" | grep -E 'Master_Host|Master_User|Slave_IO_Running|Slave_SQL_Running|Seconds_Behind_Master|Last_IO_Error|Last_SQL_Error|Using_Gtid'

echo "=== Hasil replikasi ==="
mariadb -e "SHOW DATABASES LIKE '${DB_NAME}';"
mariadb -e "USE ${DB_NAME}; SHOW TABLES; SELECT * FROM request_logs;" || true