#!/bin/bash
# Generate SSL certificates for Wazuh
# Based on: https://documentation.wazuh.com/current/deployment-options/docker/wazuh-container.html

set -e

CERTS_DIR="./config/wazuh_indexer_ssl_certs"

echo "Creating certificates directory..."
mkdir -p "$CERTS_DIR"

echo "Generating certificates using Wazuh cert tool..."

# Download and run the certificate generation tool
docker run --rm -ti \
  -v "$(pwd)/$CERTS_DIR:/certificates" \
  wazuh/wazuh-certs-generator:0.0.2 \
  -A

echo ""
echo "Certificates generated in $CERTS_DIR"
echo ""
echo "Files created:"
ls -la "$CERTS_DIR"
echo ""
echo "You can now start Wazuh with: docker compose up -d"
