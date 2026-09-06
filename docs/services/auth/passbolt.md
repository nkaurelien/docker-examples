# Passbolt Password Manager (PostgreSQL Edition)

[Passbolt](https://www.passbolt.com/) is an open-source, team-first password manager built with GPG end-to-end encryption.

---

## Service Overview

| Attribute | Details |
| :--- | :--- |
| **Service Name** | `passbolt` |
| **Public URL** | `https://passwords.kamitbrains.fr` |
| **Health Check** | `http://127.0.0.1/healthcheck/status.json` |
| **Docker Image** | `passbolt/passbolt:latest` |
| **Database** | PostgreSQL 16 Alpine (`postgres:16-alpine`) |
| **Reverse Proxy** | Traefik (`websecure` + Let's Encrypt TLS) |
| **Security** | CrowdSec ForwardAuth Bouncer |
| **Storage Volumes** | `passbolt-gpg-keys`, `passbolt-jwt-keys`, `passbolt-db-data` |

---

## Quick Start & Setup

### 1. Automated Init Container

The stack includes a `passbolt-init` container that runs automatically on first boot, verifies whether the admin user exists, and generates the registration link if missing.

To view the activation link at any time:

```bash
docker logs passbolt-init
```

### 2. Browser Extension & Mobile Apps

- **Browser Extensions**: Install Passbolt extension for Firefox, Chrome, Edge, or Brave.
- **Mobile Apps**: Passbolt apps available on iOS (App Store) and Android (Google Play).

---

## Architecture & Docker Compose Configuration

Managed via Ansible role in `ansible/roles/passbolt/`.

```yaml
services:
  passbolt-db:
    image: postgres:16-alpine
    container_name: passbolt-db
    restart: unless-stopped
    environment:
      - POSTGRES_DB=passbolt
      - POSTGRES_USER=passbolt
      - POSTGRES_PASSWORD=${PASSBOLT_DB_PASSWORD}
    volumes:
      - passbolt-db-data:/var/lib/postgresql/data
    networks:
      - passbolt-internal
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U passbolt -d passbolt || exit 1"]

  passbolt:
    image: passbolt/passbolt:latest
    container_name: passbolt
    restart: unless-stopped
    depends_on:
      passbolt-db:
        condition: service_healthy
    environment:
      - APP_FULL_BASE_URL=https://passwords.kamitbrains.fr
      - DATASOURCES_DEFAULT_DRIVER=Cake\Database\Driver\Postgres
      - DATASOURCES_DEFAULT_HOST=passbolt-db
      - DATASOURCES_DEFAULT_PORT=5432
      - DATASOURCES_DEFAULT_USERNAME=passbolt
      - DATASOURCES_DEFAULT_PASSWORD=${PASSBOLT_DB_PASSWORD}
      - DATASOURCES_DEFAULT_DATABASE=passbolt
      - DATASOURCES_DEFAULT_ENCODING=utf8
    volumes:
      - passbolt-gpg-keys:/etc/passbolt/gpg
      - passbolt-jwt-keys:/etc/passbolt/jwt
    networks:
      - traefik-public
      - passbolt-internal
```
