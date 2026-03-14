#!/bin/sh
set -e

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
CERTS_DIR="$SCRIPT_DIR/../certs"
CERT_DOMAIN="${1:-${DOMAIN_NAME:-localhost}}"
KEY_FILE="$CERTS_DIR/privkey.pem"
CERT_FILE="$CERTS_DIR/fullchain.pem"

mkdir -p "$CERTS_DIR"

if [ -f "$KEY_FILE" ] && [ -f "$CERT_FILE" ]; then
    echo "[certs] Certificates already exist in $CERTS_DIR"
    exit 0
fi

echo "[certs] Generating self-signed certificate for $CERT_DOMAIN"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CERT_FILE" \
    -subj "/C=ES/ST=Barcelona/L=Barcelona/O=Inception/CN=$CERT_DOMAIN"

echo "[certs] Created:"
echo "[certs]   $KEY_FILE"
echo "[certs]   $CERT_FILE"
