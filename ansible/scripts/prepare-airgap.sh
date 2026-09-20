#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
AIRGAP_DIR="${ANSIBLE_DIR}/airgap"

K3S_VERSION="${1:-v1.31.12+k3s1}"
ARCH="${2:-amd64}"

echo "=== Preparing Air-Gap artifacts for K3s ${K3S_VERSION} (${ARCH}) ==="
mkdir -p "${AIRGAP_DIR}"

# 1. Download install script
echo "--> Downloading k3s-install.sh..."
curl -fsSL https://get.k3s.io -o "${AIRGAP_DIR}/k3s-install.sh"
chmod +x "${AIRGAP_DIR}/k3s-install.sh"

# 2. Download k3s binary
ENCODED_VERSION="$(echo "${K3S_VERSION}" | sed 's/+/%2B/g')"
echo "--> Downloading k3s binary (${ARCH})..."
curl -fL "https://github.com/k3s-io/k3s/releases/download/${ENCODED_VERSION}/k3s" -o "${AIRGAP_DIR}/k3s"
chmod +x "${AIRGAP_DIR}/k3s"

# 3. Download airgap images
echo "--> Downloading airgap images tarball (${ARCH})..."
if ! curl -fL "https://github.com/k3s-io/k3s/releases/download/${ENCODED_VERSION}/k3s-airgap-images-${ARCH}.tar.zst" -o "${AIRGAP_DIR}/k3s-airgap-images-${ARCH}.tar.zst"; then
    echo "tar.zst not found, falling back to tar.gz..."
    curl -fL "https://github.com/k3s-io/k3s/releases/download/${ENCODED_VERSION}/k3s-airgap-images-${ARCH}.tar.gz" -o "${AIRGAP_DIR}/k3s-airgap-images-${ARCH}.tar.gz"
fi

echo "=== Airgap artifacts ready in ${AIRGAP_DIR} ==="
ls -lh "${AIRGAP_DIR}"
