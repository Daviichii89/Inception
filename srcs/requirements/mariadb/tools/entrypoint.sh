#!/bin/sh
set -e

DATADIR="/var/lib/mysql"
RUNDIR="/run/mysqld"
SOCKET="$RUNDIR/mysqld.sock"

echo "[entrypoint] Setting permissions..."
mkdir -p "$DATADIR" "$RUNDIR"
chown -R mysql:mysql "$DATADIR" "$RUNDIR"

if [ -f /run/secrets/wp_db_password ]; then
    WP_PASS="$(cat /run/secrets/wp_db_password)"
else
    WP_PASS="${WORDPRESS_DB_PASSWORD:-}"
fi

if [ ! -d "$DATADIR/mysql" ]; then
    echo "[entrypoint] Initializing MariaDB system tables..."
    mysql_install_db --user=mysql --datadir="$DATADIR" >/dev/null
fi

echo "[entrypoint] Starting temporary MariaDB server..."
su mysql -s /bin/sh -c "mysqld --skip-networking --socket=$SOCKET --datadir=$DATADIR" &
TEMP_PID=$!

for i in $(seq 1 30); do
    if mysqladmin --protocol=socket --socket="$SOCKET" ping --silent >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

if ! mysqladmin --protocol=socket --socket="$SOCKET" ping --silent >/dev/null 2>&1; then
    echo "[entrypoint] ERROR: MariaDB did not start for initialization."
    exit 1
fi

echo "[entrypoint] MariaDB is up, ensuring WordPress database and user..."

mysql --protocol=socket --socket="$SOCKET" -uroot <<EOSQL
CREATE DATABASE IF NOT EXISTS \`${WORDPRESS_DB_NAME}\`;
CREATE USER IF NOT EXISTS '${WORDPRESS_DB_USER}'@'%' IDENTIFIED BY '${WP_PASS}';
ALTER USER '${WORDPRESS_DB_USER}'@'%' IDENTIFIED BY '${WP_PASS}';
GRANT ALL PRIVILEGES ON \`${WORDPRESS_DB_NAME}\`.* TO '${WORDPRESS_DB_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL

echo "[entrypoint] Initialization complete."

mysqladmin --protocol=socket --socket="$SOCKET" -uroot shutdown || kill "$TEMP_PID"

echo "[entrypoint] Launching MariaDB..."
exec su mysql -s /bin/sh -c "mysqld --datadir=$DATADIR"
