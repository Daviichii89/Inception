#!/bin/sh
set -e

DATADIR="/var/lib/mysql"
RUNDIR="/run/mysqld"

echo "[entrypoint] Setting permissions…"
mkdir -p "$DATADIR" "$RUNDIR"
chown -R mysql:mysql "$DATADIR" "$RUNDIR"

# ------------------------------------------------------------
# 1. LEER SECRETS
# ------------------------------------------------------------
if [ -f /run/secrets/mariadb_root_password ]; then
    ROOT_PASS="$(cat /run/secrets/mariadb_root_password)"
else
    ROOT_PASS="${MYSQL_ROOT_PASSWORD:-}"
fi

if [ -f /run/secrets/wp_db_password ]; then
    WP_PASS="$(cat /run/secrets/wp_db_password)"
else
    WP_PASS="${WORDPRESS_DB_PASSWORD:-}"
fi

WP_DB="${WORDPRESS_DB_NAME:-wordpress}"
WP_USER="${WORDPRESS_DB_USER:-wp_user}"

# ------------------------------------------------------------
# 2. INICIALIZAR DATOS SI EL DIRECTORIO ESTÁ VACÍO
# ------------------------------------------------------------
if [ -z "$(ls -A "$DATADIR")" ]; then
    echo "[entrypoint] Initializing MariaDB system tables..."
    mysql_install_db --user=mysql --datadir="$DATADIR" >/dev/null
fi

# ------------------------------------------------------------
# 3. ARRANCAR TEMPORALMENTE MARIADB PARA CONFIGURAR ROOT/USER
# ------------------------------------------------------------
echo "[entrypoint] Starting temporary MariaDB server…"
su mysql -s /bin/sh -c "mysqld --skip-networking --datadir=$DATADIR" &
TEMP_PID=$!

# Esperar a que arranque
for i in $(seq 1 30); do
    if mysqladmin ping >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

if ! mysqladmin ping >/dev/null 2>&1; then
    echo "[entrypoint] ERROR: MariaDB did not start for initialization."
    exit 1
fi

echo "[entrypoint] MariaDB is up, configuring…"

# ------------------------------------------------------------
# 4. APLICAR PASSWORD ROOT Y CREAR DB / USER
# ------------------------------------------------------------
mysql <<EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS \`${WP_DB}\`;
CREATE USER IF NOT EXISTS '${WP_USER}'@'%' IDENTIFIED BY '${WP_PASS}';
GRANT ALL PRIVILEGES ON \`${WP_DB}\`.* TO '${WP_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL

echo "[entrypoint] Initialization complete."

# Apagar el servidor temporal
mysqladmin -uroot -p"${ROOT_PASS}" shutdown || kill "$TEMP_PID"

# ------------------------------------------------------------
# 5. ARRANCAR MARIADB DEFINITIVO EN FOREGROUND
# ------------------------------------------------------------
echo "[entrypoint] Launching MariaDB..."
exec su mysql -s /bin/sh -c "mysqld --datadir=$DATADIR"
