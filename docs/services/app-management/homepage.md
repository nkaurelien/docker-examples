# Homepage Infrastructure Dashboard

[Homepage](https://gethomepage.dev/) is a modern, highly customizable application dashboard that centralizes shortcuts, status widgets, and docker container status across your infrastructure.

---

## Service Overview

| Attribute | Details |
| :--- | :--- |
| **Service Name** | `homepage` |
| **Primary URL** | `https://home.kamitbrains.fr` |
| **Alias URL** | `https://apps.kamitbrains.fr` |
| **Health Check** | `http://127.0.0.1:3000/` |
| **Docker Image** | `ghcr.io/gethomepage/homepage:latest` |
| **Reverse Proxy** | Traefik (`websecure` + Let's Encrypt TLS) |
| **Security** | CrowdSec ForwardAuth Bouncer |
| **Storage Directory** | `/opt/homepage/config` |

---

## Access & Features

- **Dual Domain Host Routing**: Access the portal from either `https://home.kamitbrains.fr` or `https://apps.kamitbrains.fr`.
- **Integrated Services**:
  - **Passbolt** (`https://passwords.kamitbrains.fr`)
  - **ChangeDetection** (`https://changedetection.kamitbrains.fr`)
  - **IT-Tools** (`https://tools.kamitbrains.fr`)
  - **Uptime Kuma** (`https://uptime.kamitbrains.fr`)
  - **Ntfy** (`https://ntfy.kamitbrains.fr`)
  - **Arcane** (`https://arcane.kamitbrains.fr`)
  - **Glances** (`https://glances.kamitbrains.fr`)
  - **TinyAuth** (`https://auth.kamitbrains.fr`)
  - **Traefik** (`https://traefik.kamitbrains.fr`)
- **System Metrics**: Real-time CPU, RAM, and disk utilization widgets.

---

## Architecture & Docker Compose Configuration

Managed via Ansible role in `ansible/roles/homepage/`.

```yaml
services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    restart: unless-stopped
    volumes:
      - ./config:/app/config
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.homepage.rule=Host(`home.kamitbrains.fr`) || Host(`apps.kamitbrains.fr`)"
      - "traefik.http.routers.homepage.entrypoints=websecure"
      - "traefik.http.routers.homepage.tls.certresolver=letsencrypt"
      - "traefik.http.routers.homepage.middlewares=crowdsec-bouncer@file"
      - "traefik.http.services.homepage.loadbalancer.server.port=3000"
```
