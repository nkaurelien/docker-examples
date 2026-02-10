#!/usr/bin/env bash
# Generate SSL certificates for the local Docker registry using mkcert.
#
# Usage:
#   bash ssl/generate-certs.sh [DOMAIN]
#
# Default domain: registry.localhost
set -euo pipefail

DOMAIN="${1:-registry.localhost}"
CERT_DIR="$(cd "$(dirname "$0")" && pwd)/certs"

# --- Check / install mkcert -------------------------------------------
if ! command -v mkcert &>/dev/null; then
  echo "mkcert not found. Installing..."
  if command -v brew &>/dev/null; then
    brew install mkcert
  elif command -v apt-get &>/dev/null; then
    sudo apt-get update && sudo apt-get install -y mkcert
  elif command -v choco &>/dev/null; then
    choco install mkcert
  else
    echo "ERROR: Cannot install mkcert automatically."
    echo "Install manually: https://github.com/FiloSottile/mkcert#installation"
    exit 1
  fi
fi

# --- Install local CA (if not already) ---------------------------------
echo "Installing local CA (may prompt for sudo)..."
mkcert -install

# --- Generate certs ----------------------------------------------------
mkdir -p "$CERT_DIR"
echo "Generating certificates for: $DOMAIN, *.$DOMAIN, localhost"
mkcert -cert-file "$CERT_DIR/$DOMAIN.pem" \
       -key-file  "$CERT_DIR/$DOMAIN-key.pem" \
       "$DOMAIN" "*.$DOMAIN" localhost 127.0.0.1 ::1

echo ""
echo "Certificates generated:"
echo "  $CERT_DIR/$DOMAIN.pem"
echo "  $CERT_DIR/$DOMAIN-key.pem"
echo ""
echo "Next steps:"
echo "  1. Restart Docker Desktop (so it picks up the new CA)"
echo "  2. Add to /etc/hosts:  127.0.0.1  $DOMAIN"
echo "  3. Start services:     docker compose -f compose.yml -f compose.nginx.yml up -d"
echo "  4. Verify:             curl -s https://$DOMAIN/router/api/v1/system/health"