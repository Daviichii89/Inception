#!/bin/sh
set -e

WWW_ROOT="/var/www/html"

if [ -w "$WWW_ROOT" ]; then
	echo "[entrypoint] $WWW_ROOT it's writable - adjusting permissions"
	chown -R www-data:www-data /var/www/html || true
else
	echo "[entrypoint] $WWW_ROOT it's read-only"
fi

# Validar certificados mínimos
if [ ! -f /etc/ssl/certs/fullchain.pem ] || [ ! -f /etc/ssl/certs/privkey.pem ]; then
  echo "[entrypoint] Warning: Certificates not found in /etc/ssl/certs; generating temporary self-signed certificates"
  mkdir -p /etc/ssl/certs
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/certs/privkey.pem -out /etc/ssl/certs/fullchain.pem \
    -subj "/C=ES/ST=Barcelona/L=Barcelona/O=Inception/CN=localhost"
fi

# Lanzar nginx en primer plano
echo "[entrypoint] Launching nginx..."
exec nginx -g 'daemon off;'
