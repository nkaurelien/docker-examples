#!/bin/bash
# Install mkcert root CA into the host system trust store
# Usage: ./install-ca.sh [omgwtfssl|mkcert]
# Default: mkcert

set -euo pipefail

TOOL="${1:-mkcert}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

case "$TOOL" in
  mkcert)
    CA_CERT="$SCRIPT_DIR/certs/mkcert/ca/rootCA.pem"
    CA_NAME="mkcert-dev-ca"
    ;;
  omgwtfssl)
    CA_CERT="$SCRIPT_DIR/certs/omgwtfssl/ca.pem"
    CA_NAME="omgwtfssl-dev-ca"
    ;;
  openssl)
    # openssl generates a self-signed cert (the cert IS the CA)
    CA_CERT="$SCRIPT_DIR/certs/openssl/cert.pem"
    CA_NAME="openssl-dev-ca"
    ;;
  *)
    echo "Usage: $0 [mkcert|omgwtfssl|openssl]"
    exit 1
    ;;
esac

if [ ! -f "$CA_CERT" ]; then
  echo "Error: CA certificate not found at $CA_CERT"
  echo "Run 'docker compose --profile $TOOL up' first to generate certificates."
  exit 1
fi

echo "Installing CA certificate: $CA_CERT"

OS="$(uname -s)"
case "$OS" in
  Darwin)
    echo "Detected: macOS"
    echo "Adding CA to system keychain (requires sudo)..."
    sudo security add-trusted-cert -d -r trustRoot \
      -k /Library/Keychains/System.keychain "$CA_CERT"
    echo "Done. The CA is now trusted by macOS and Chrome/Safari."
    echo "For Firefox: import manually via Preferences > Certificates > Import ($CA_CERT)"
    ;;
  Linux)
    echo "Detected: Linux"
    if command -v update-ca-certificates &>/dev/null; then
      # Debian/Ubuntu
      echo "Installing via update-ca-certificates (requires sudo)..."
      sudo cp "$CA_CERT" "/usr/local/share/ca-certificates/${CA_NAME}.crt"
      sudo update-ca-certificates
    elif command -v update-ca-trust &>/dev/null; then
      # RHEL/CentOS/Fedora
      echo "Installing via update-ca-trust (requires sudo)..."
      sudo cp "$CA_CERT" "/etc/pki/ca-trust/source/anchors/${CA_NAME}.pem"
      sudo update-ca-trust extract
    else
      echo "Error: Could not detect certificate trust manager."
      echo "Manually copy $CA_CERT to your system's CA trust store."
      exit 1
    fi
    echo "Done. The CA is now trusted system-wide."
    echo "For Firefox: import manually via Preferences > Certificates > Import ($CA_CERT)"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    echo "Detected: Windows (Git Bash/MSYS)"
    echo "Run this command in an elevated PowerShell:"
    echo ""
    echo "  Import-Certificate -FilePath \"$CA_CERT\" -CertStoreLocation Cert:\\LocalMachine\\Root"
    echo ""
    ;;
  *)
    echo "Unsupported OS: $OS"
    echo "Manually import $CA_CERT into your system's trusted CA store."
    exit 1
    ;;
esac
