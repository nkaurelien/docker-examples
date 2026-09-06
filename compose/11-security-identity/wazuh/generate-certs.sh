#!/bin/bash
# Generate SSL certificates for Wazuh 5.1.0 using 4.9 certs tool
# Based on: https://documentation.wazuh.com/current/deployment-options/docker/wazuh-container.html

set -e

CONFIG_DIR="./config"

echo "Creating configuration and output directories..."
mkdir -p "$CONFIG_DIR"
mkdir -p "$CONFIG_DIR/root-ca/certs"
mkdir -p "$CONFIG_DIR/wazuh_indexer/certs"
mkdir -p "$CONFIG_DIR/wazuh_manager/certs"
mkdir -p "$CONFIG_DIR/wazuh_dashboard/certs"
mkdir -p "$CONFIG_DIR/temp_certs"

echo "Generating certificates using Wazuh cert tool..."

# Run the certificate generation tool mapping the config folder and temp_certs folder
docker run --rm \
  -e CERT_TOOL_VERSION="4.14" \
  -v "$(pwd)/$CONFIG_DIR:/config" \
  -v "$(pwd)/$CONFIG_DIR/temp_certs:/certificates" \
  wazuh/wazuh-certs-generator:0.0.4 \
  -A

echo "Distributing certificates to target folders..."
cp "$CONFIG_DIR/temp_certs/root-ca.pem" "$CONFIG_DIR/root-ca/certs/root-ca.pem"
cp "$CONFIG_DIR/temp_certs/admin.pem" "$CONFIG_DIR/wazuh_indexer/certs/admin.pem"
cp "$CONFIG_DIR/temp_certs/admin-key.pem" "$CONFIG_DIR/wazuh_indexer/certs/admin-key.pem"
cp "$CONFIG_DIR/temp_certs/wazuh.indexer.pem" "$CONFIG_DIR/wazuh_indexer/certs/wazuh.indexer.pem"
cp "$CONFIG_DIR/temp_certs/wazuh.indexer-key.pem" "$CONFIG_DIR/wazuh_indexer/certs/wazuh.indexer-key.pem"
cp "$CONFIG_DIR/temp_certs/wazuh.manager.pem" "$CONFIG_DIR/wazuh_manager/certs/wazuh.manager.pem"
cp "$CONFIG_DIR/temp_certs/wazuh.manager-key.pem" "$CONFIG_DIR/wazuh_manager/certs/wazuh.manager-key.pem"
cp "$CONFIG_DIR/temp_certs/wazuh.dashboard.pem" "$CONFIG_DIR/wazuh_dashboard/certs/wazuh.dashboard.pem"
cp "$CONFIG_DIR/temp_certs/wazuh.dashboard-key.pem" "$CONFIG_DIR/wazuh_dashboard/certs/wazuh.dashboard-key.pem"

echo "Cleaning up temporary files..."
rm -rf "$CONFIG_DIR/temp_certs"

echo ""
echo "Certificates successfully generated and organized!"
echo ""
echo "Files created:"
find "$CONFIG_DIR" -type f
echo ""
echo "You can now start Wazuh with: docker compose up -d"
