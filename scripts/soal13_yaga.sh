#!/bin/bash
# Nomor 13 - MariaDB Master (yaga)
# Jalankan di yaga:  bash /root/yaga-master.sh
set -e

DB_NAME="${DB_NAME:-db_shibuya_K42}"
APP_USER="${APP_USER:-k42_user}"
APP_PASS="${APP_PASS:-k42pass}"
REPL_USER="${REPL_USER:-repl}"
REPL_PASS="${REPL_PASS:-replpass}"
NET4_HOST="192.232.4.%"

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

# 2. Konfigurasi Master: bind semua interface, server-id, binary log
cat > /etc/mysql/mariadb.conf.d/99-replication.cnf << CNF
[mysqld]
bind-address     = 0.0.0.0
skip-name-resolve
server-id        = 1
log_bin          = /var/log/mysql/mysql-bin.log
binlog_format    = ROW
CNF

# 3. Restart agar konfigurasi aktif
stop_mariadb
start_mariadb

# 4. Database, tabel, dan user
mariadb << SQL
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
USE ${DB_NAME};
CREATE TABLE IF NOT EXISTS request_logs (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    client_ip    VARCHAR(45)  NOT NULL,
    request_path VARCHAR(255) NOT NULL,
    http_method  VARCHAR(10)  NOT NULL DEFAULT 'GET',
    status_code  INT          NOT NULL DEFAULT 200,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Hak akses remote untuk seluruh node Network 4
CREATE USER IF NOT EXISTS '${APP_USER}'@'${NET4_HOST}' IDENTIFIED BY '${APP_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${APP_USER}'@'${NET4_HOST}';

-- User replikasi untuk Slave
CREATE USER IF NOT EXISTS '${REPL_USER}'@'${NET4_HOST}' IDENTIFIED BY '${REPL_PASS}';
GRANT REPLICATION SLAVE ON *.* TO '${REPL_USER}'@'${NET4_HOST}';
FLUSH PRIVILEGES;
SQL

# 5. Verifikasi
echo "=== Binary log & server-id ==="
mariadb -e "SHOW VARIABLES WHERE Variable_name IN ('log_bin','server_id','binlog_format','bind_address');"
echo "=== Master status ==="
mariadb -e "SHOW MASTER STATUS;"
echo "=== Tabel ==="
mariadb -e "USE ${DB_NAME}; SHOW TABLES; DESCRIBE request_logs;"
echo "=== Grants ==="
mariadb -e "SHOW GRANTS FOR '${APP_USER}'@'${NET4_HOST}'; SHOW GRANTS FOR '${REPL_USER}'@'${NET4_HOST}';"
echo "=== Listen port 3306 ==="
ss -lntp | grep 3306 || true