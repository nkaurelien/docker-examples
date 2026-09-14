# Syncthing — Continuous P2P File Synchronization

[Syncthing](https://syncthing.net/) is an open-source, continuous, peer-to-peer (P2P), encrypted file synchronization platform.

---

## 1. Overview & Architecture

Syncthing replaces proprietary cloud sync services (like Dropbox or Google Drive) with a decentralized, private, peer-to-peer file synchronization system.

- **Main Web GUI**: `https://syncthing.kamitbrains.fr`
- **Alias URL**: `https://sync.kamitbrains.fr`
- **Network Protocol Ports**:
  - `8384` : Web GUI (Proxied via Traefik HTTPS)
  - `22000/tcp` + `22000/udp` : P2P Sync Traffic
  - `21027/udp` : Local Discovery

---

## 2. Key Features

- **P2P & Decentralized**: Direct device-to-device transfer without third-party cloud servers.
- **End-to-End Encryption (E2EE)**: All communication is secured via TLS 1.3 with Perfect Forward Secrecy.
- **Block-Level Delta Sync**: Transfers only modified chunks of large files.
- **Automated Paperless-ngx Ingestion**: Ideal for syncing a `Scans` folder from mobile/desktop directly into Paperless-ngx `/opt/paperless/consume` directory.

---

## 3. Deployment with Ansible

To deploy Syncthing on all infrastructure hosts:

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags syncthing
```
