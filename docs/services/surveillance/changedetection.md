---
tags: changedetection, surveillance, web, website-monitoring
---

# ChangeDetection.io Web Surveillance

[ChangeDetection.io](https://changedetection.io/) is an open-source web page change monitoring and notification service.

---

## Service Overview

| Attribute | Details |
| :--- | :--- |
| **Service Name** | `changedetection` |
| **Public URL** | `https://changedetection.kamitbrains.fr` |
| **Health Check** | `http://127.0.0.1:5000/` |
| **Docker Image** | `dgtlmoon/changedetection.io:latest` |
| **Internal Port** | `5000` |
| **Reverse Proxy** | Traefik (`websecure` + Let's Encrypt TLS) |
| **Security** | CrowdSec ForwardAuth Bouncer |
| **Storage Volumes** | `changedetection-data` |

---

## Quick Start & Usage

1. Open **`https://changedetection.kamitbrains.fr`**.
2. Add a URL to watch (e.g., website price changes, API updates, or release pages).
3. Configure notification URL (e.g., `https://ntfy.kamitbrains.fr/system-alerts`).

---

## Architecture & Docker Compose Configuration

Managed via Ansible role in `ansible/roles/changedetection/`.

```yaml
services:
  changedetection:
    image: dgtlmoon/changedetection.io:latest
    container_name: changedetection
    restart: unless-stopped
    environment:
      - BASE_URL=https://changedetection.kamitbrains.fr
      - HIDE_REFERER=true
    volumes:
      - changedetection-data:/datastore
    networks:
      - traefik-public
```
