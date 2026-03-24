
#!/bin/sh
set -e

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
CERTS_DIR="$SCRIPT_DIR/../certs"
CERT_DOMAIN="${1:-${DOMAIN_NAME:-localhost}}"
KEY_FILE="$CERTS_DIR/privkey.pem"
CERT_FILE="$CERTS_DIR/fullchain.pem"

mkdir -p "$CERTS_DIR"
CERTS_DIR="$(CDPATH= cd -- "$CERTS_DIR" && pwd)"
KEY_FILE="$CERTS_DIR/privkey.pem"
CERT_FILE="$CERTS_DIR/fullchain.pem"

if [ -f "$KEY_FILE" ] && [ -f "$CERT_FILE" ]; then
    if openssl x509 -checkend 0 -noout -in "$CERT_FILE" >/dev/null 2>&1; then
        echo "Valid certificate already exists in $CERTS_DIR"
        exit 0
    fi

    echo "Existing certificate is expired or invalid, regenerating"
fi

echo "Generating self-signed certificate for $CERT_DOMAIN"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CERT_FILE" \
    -subj "/C=ES/ST=Barcelona/L=Barcelona/O=Inception/CN=$CERT_DOMAIN"

echo "Created:"
echo "$KEY_FILE"
echo "$CERT_FILE"
