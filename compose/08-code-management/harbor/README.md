---
tags: harbor, oci, registry, docker, trivy, code-management
---

# Harbor OCI & Artifact Registry

[Harbor](https://goharbor.io/) is an open-source trusted cloud-native artifact registry that stores, signs, and scans content.

## Features

- **OCI Registry**: Store Docker/Helm/Wasm OCI compliance images.
- **Trivy Vulnerability Scanner**: Automated vulnerability scanning on image push.
- **Cosign & Notation Signing**: Cryptographic artifact verification.
- **Traefik & SSL**: Automatic HTTPS TLS termination and CrowdSec bouncer protection.

## Deployment via Ansible

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags harbor --limit homelab_server
```

## Docker CLI Login

```bash
docker login harbor.example.com -u admin -p <ADMIN_PASSWORD>
```
