#!/bin/sh
set -e

WWW_ROOT="/var/www/html"
WP_CLI="/usr/local/bin/wp"

# Asegurar permisos para www-data
mkdir -p "$WWW_ROOT"
chown -R www-data:www-data "$WWW_ROOT"

WORDPRESS_ROOT_PASS="$(cat /run/secrets/wp_root_password)"
WORDPRESS_USER_PASS="$(cat /run/secrets/wp_user_password)"

# Si no existe wp-config.php, generar uno básico usando env/secrets
if [ ! -f "$WWW_ROOT/wp-config.php" ]; then
  echo "[entrypoint] Generando wp-config.php básico"
  # obtener credenciales (revisamos secrets primero)
  if [ -f /run/secrets/wp_db_password ]; then
    DB_PASS="$(cat /run/secrets/wp_db_password)"
  else
    DB_PASS="${WORDPRESS_DB_PASSWORD:-}"
  fi
  DB_HOST="${WORDPRESS_DB_HOST:-mariadb:3306}"
  DB_NAME="${WORDPRESS_DB_NAME:-wordpress}"
  DB_USER="${WORDPRESS_DB_USER:-root}"

  # Usamos wp-config-sample.php para crear wp-config.php con valores mínimos
  cp "$WWW_ROOT/wp-config-sample.php" "$WWW_ROOT/wp-config.php"
  sed -i "s/database_name_here/$DB_NAME/" "$WWW_ROOT/wp-config.php"
  sed -i "s/username_here/$DB_USER/" "$WWW_ROOT/wp-config.php"
  sed -i "s/password_here/$DB_PASS/" "$WWW_ROOT/wp-config.php"
  sed -i "s/localhost/$DB_HOST/" "$WWW_ROOT/wp-config.php"

  chown www-data:www-data "$WWW_ROOT/wp-config.php"
fi

wait_for_db() {
  tries=0
  max=30
  until php -r "new mysqli('${WORDPRESS_DB_HOST:-mariadb}','${WORDPRESS_DB_USER:-wp_user}','$(cat /run/secrets/wp_db_password 2>/dev/null || echo ${WORDPRESS_DB_PASSWORD:-})','${WORDPRESS_DB_NAME:-wordpress}');" >/dev/null 2>&1
  do
    tries=$((tries+1))
    if [ "$tries" -ge "$max" ]; then
      echo "[entrypoint] ERROR: DB unreachable after $max attempts" >&2
      return 1
    fi
    sleep 1
  done
  return 0
}

wait_for_db

su -s /bin/sh www-data -c "cd '$WWW_ROOT' && \
    if ! $WP_CLI core is-installed --path='$WWW_ROOT' >/dev/null 2>&1; then
      echo '[entrypoint] WordPress not installed: running wp core install...'
      # use --skip-email to avoid try send emails
      $WP_CLI core install \
        --url='${WORDPRESS_URL}' \
        --title='${WORDPRESS_TITLE}' \
        --admin_user='${WORDPRESS_ROOT}' \
        --admin_password='${WORDPRESS_ROOT_PASS}' \
        --admin_email='${WORDPRESS_ROOT_EMAIL}' \
        --path='$WWW_ROOT' \
        --skip-email

      $WP_CLI user create '${WORDPRESS_USER}' '${WORDPRESS_USER_EMAIL}' \
          --user_pass='${WORDPRESS_USER_PASS}' \
          --role='author' --path='$WWW_ROOT'
    fi"
# Ejecutar PHP-FPM en primer plano
exec php-fpm8.2 -F
