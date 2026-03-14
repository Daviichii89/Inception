#!/bin/sh
set -e

WWW_ROOT="/var/www/html"

if [ -w "$WWW_ROOT" ]; then
	echo "[entrypoint] $WWW_ROOT it's writable - adjusting permissions"
	chown -R www-data:www-data /var/www/html || true
else
	echo "[entrypoint] $WWW_ROOT it's read-only"
fi

# Lanzar nginx en primer plano
echo "[entrypoint] Launching nginx..."
exec nginx -g 'daemon off;'
