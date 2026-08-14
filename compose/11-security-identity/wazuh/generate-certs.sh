#!/bin/bash
# Generate SSL certificates for Wazuh 5.1.0
# Based on: https://documentation.wazuh.com/current/deployment-options/docker/wazuh-container.html

set -e

CONFIG_DIR="./config"

echo "Creating config directory..."
mkdir -p "$CONFIG_DIR"

echo "Generating certificates using Wazuh cert tool..."

# Run the certificate generation tool mapping the config folder
docker run --rm \
  -v "$(pwd)/$CONFIG_DIR:/config" \
  wazuh/wazuh-certs-generator:0.0.4 \
  -A

echo ""
echo "Certificates generated in $CONFIG_DIR"
echo ""
echo "Files created:"
find "$CONFIG_DIR" -type f
echo ""
echo "You can now start Wazuh with: docker compose up -d"
