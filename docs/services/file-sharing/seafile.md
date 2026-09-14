# Seafile — Enterprise File Sync & Share Platform

[Seafile](https://www.seafile.com/) is an open-source, high-performance file sync and share solution with encryption, library organization, and team collaboration capabilities.

---

## 1. Overview & Architecture

Seafile provides a robust cloud storage interface with desktop/mobile client synchronization, public file link sharing, and encrypted library storage.

- **Main Web GUI**: `https://seafile.kamitbrains.fr`
- **Alias URL**: `https://drive.kamitbrains.fr`
- **Default Admin Email**: `admin@kamitbrains.fr`
- **Backend Stack**:
  - `seafile` : Seafile Server & Seahub Web Interface (`seafileltd/seafile-mc:latest`)
  - `seafile-db` : MariaDB 10.11 Database (`mariadb:10.11`)
  - `seafile-memcached` : Memcached Cache (`memcached:1.6-alpine`)

---

## 2. Key Features

- **High Performance**: Fast file indexing and sync via C/Python architecture.
- **Encrypted Libraries**: Client-side encrypted libraries for sensitive file storage.
- **Team Collaboration**: Granular permissions, link sharing, and version history.
- **Traefik & CrowdSec Protection**: HTTPS TLS termination with automated LAPI bouncer security.

---

## 3. Deployment with Ansible

To deploy Seafile on all infrastructure hosts:

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags seafile
```
