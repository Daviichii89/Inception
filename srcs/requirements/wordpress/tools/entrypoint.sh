#!/bin/sh
set -e

WWW_ROOT="/var/www/html"

# Asegurar permisos para www-data
mkdir -p "$WWW_ROOT"
chown -R www-data:www-data "$WWW_ROOT"

# Si no existe wp-config.php, generar uno básico usando env/secrets
if [ ! -f "$WWW_ROOT/wp-config.php" ]; then
  echo "[entrypoint] Generando wp-config.php básico"
  # obtener credenciales (revisamos secrets primero)
  if [ -f /run/secrets/wp_db_password ]; then
    DB_PASS="$(cat /run/secrets/wp_db_password)"
  else
    DB_PASS="${WORDPRESS_DB_PASSWORD:-}"
  fi
  DB_HOST="${WORDPRESS_DB_HOST:-db:3306}"
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

# Ejecutar PHP-FPM en primer plano
exec php-fpm8.2 -F
