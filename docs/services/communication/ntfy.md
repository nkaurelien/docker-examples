# Ntfy Push Notification Service

[ntfy](https://ntfy.sh/) is a simple HTTP-based pub-sub notification service that allows you to send push notifications to your phone or desktop via scripts, cURL, or webhooks.

---

## Service Overview

| Attribute | Details |
| :--- | :--- |
| **Service Name** | `ntfy` |
| **Public URL** | `https://ntfy.kamitbrains.fr` |
| **Health Check** | `https://ntfy.kamitbrains.fr/v1/health` |
| **Docker Image** | `binwiederhier/ntfy:v2.11.0` |
| **Internal Port** | `80` |
| **Reverse Proxy** | Traefik (`websecure` + Let's Encrypt TLS) |
| **Security** | CrowdSec ForwardAuth Bouncer |
| **Storage Volumes** | `ntfy-cache`, `ntfy-etc` |

---

## Quick Start: Sending Push Notifications

### 1. Publish a Message via cURL

```bash
curl -d "Disk usage alert on Contabo server" https://ntfy.kamitbrains.fr/system-alerts
```

### 2. Publish with Title, Tags, and Priority

```bash
curl \
  -H "Title: Backup Successful" \
  -H "Tags: white_check_mark,database" \
  -H "Priority: high" \
  -d "Database backup completed successfully in 45 seconds." \
  https://ntfy.kamitbrains.fr/backups
```

### 3. Subscribe to a Topic

- **Android / iOS App**: Open the official **ntfy** mobile application, add custom server `https://ntfy.kamitbrains.fr`, and subscribe to topic `system-alerts`.
- **Web Interface**: Open `https://ntfy.kamitbrains.fr` in any browser to view live topics.

---

## Architecture & Docker Compose Configuration

The service is managed via Ansible in `ansible/roles/ntfy/`.

```yaml
services:
  ntfy:
    image: binwiederhier/ntfy:v2.11.0
    container_name: ntfy
    restart: unless-stopped
    command:
      - serve
    environment:
      - NTFY_BASE_URL=https://ntfy.kamitbrains.fr
      - NTFY_CACHE_FILE=/var/cache/ntfy/cache.db
      - NTFY_BEHIND_PROXY=true
    volumes:
      - ntfy-cache:/var/cache/ntfy
      - ntfy-etc:/etc/ntfy
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.ntfy.rule=Host(`ntfy.kamitbrains.fr`)"
      - "traefik.http.routers.ntfy.entrypoints=websecure"
      - "traefik.http.routers.ntfy.tls.certresolver=letsencrypt"
      - "traefik.http.routers.ntfy.middlewares=crowdsec-bouncer@file"
      - "traefik.http.services.ntfy.loadbalancer.server.port=80"
```

---

## Monitoring & Systemd Integration

- **Uptime Kuma**: Automatically monitored at `https://ntfy.kamitbrains.fr/v1/health`.
- **Systemd Service**: Managed via `ntfy.service` for automatic boot startup.
