# Passbolt Password Manager

[Passbolt](https://www.passbolt.com/) is an open-source, team-first password manager built with GPG end-to-end encryption.

---

## Service Overview

| Attribute | Details |
| :--- | :--- |
| **Service Name** | `passbolt` |
| **Public URL** | `https://passwords.kamitbrains.fr` |
| **Health Check** | `http://127.0.0.1/healthcheck/status.json` |
| **Docker Image** | `passbolt/passbolt:latest-ce` |
| **Database** | MariaDB 10.11 (`passbolt-db`) |
| **Reverse Proxy** | Traefik (`websecure` + Let's Encrypt TLS) |
| **Security** | CrowdSec ForwardAuth Bouncer |
| **Storage Volumes** | `passbolt-gpg-keys`, `passbolt-jwt-keys`, `passbolt-db-data` |

---

## Quick Start & Setup

### 1. Register First Administrator User

Run the following command on the server via `docker exec`:

```bash
docker exec -u www-data passbolt /usr/share/php/passbolt/bin/cake passbolt register_user \
  -u admin@kamitbrains.fr -f Admin -l User -r admin
```

The output will contain an activation link (e.g., `https://passwords.kamitbrains.fr/setup/start/...`). Click the link to set up your GPG key pair and master password in the browser extension.

### 2. Browser Extension & Mobile Apps

- **Browser Extensions**: Install Passbolt extension for Firefox, Chrome, Edge, or Brave.
- **Mobile Apps**: Passbolt apps available on iOS (App Store) and Android (Google Play).

---

## Architecture & Docker Compose Configuration

Managed via Ansible role in `ansible/roles/passbolt/`.

```yaml
services:
  passbolt-db:
    image: mariadb:10.11
    container_name: passbolt-db
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_PASSWORD=${PASSBOLT_DB_PASSWORD}
      - MYSQL_DATABASE=passbolt
      - MYSQL_USER=passbolt
      - MYSQL_PASSWORD=${PASSBOLT_DB_PASSWORD}
    volumes:
      - passbolt-db-data:/var/lib/mysql
    networks:
      - passbolt-internal

  passbolt:
    image: passbolt/passbolt:latest-ce
    container_name: passbolt
    restart: unless-stopped
    depends_on:
      passbolt-db:
        condition: service_healthy
    environment:
      - APP_FULL_BASE_URL=https://passwords.kamitbrains.fr
      - DATASOURCES_DEFAULT_HOST=passbolt-db
      - DATASOURCES_DEFAULT_USERNAME=passbolt
      - DATASOURCES_DEFAULT_PASSWORD=${PASSBOLT_DB_PASSWORD}
      - DATASOURCES_DEFAULT_DATABASE=passbolt
    volumes:
      - passbolt-gpg-keys:/etc/passbolt/gpg
      - passbolt-jwt-keys:/etc/passbolt/jwt
    networks:
      - traefik-public
      - passbolt-internal
```
