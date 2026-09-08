---
tags: dev-tools, developer, developer-utilities, it-tools, web
---

# IT-Tools Web Developer Tools Collection

[IT-Tools](https://it-tools.tech/) is an open-source collection of handy online tools for developers and system administrators.

---

## Service Overview

| Attribute | Details |
| :--- | :--- |
| **Service Name** | `it-tools` |
| **Public URL** | `https://tools.kamitbrains.fr` |
| **Health Check** | `http://127.0.0.1:80/` |
| **Docker Image** | `corentinth/it-tools:latest` |
| **Internal Port** | `80` |
| **Reverse Proxy** | Traefik (`websecure` + Let's Encrypt TLS) |
| **Security** | CrowdSec ForwardAuth Bouncer |
| **Storage** | Stateless static single-page app |

---

## Features

- **Generators**: UUID/GUID, Passwords, Hash (MD5, SHA-256, bcrypt), QR Code, Lorem Ipsum, HMAC.
- **Converters**: JSON ↔ YAML, JSON ↔ XML, Base64, Case Converter, Number Base.
- **Network Tools**: Subnet calculator, IPv6 ULA generator, MAC address vendor lookup.
- **Text & Code**: Text diff viewer, Regex tester, Cron expression parser, HTML/URL escape.

---

## Architecture & Docker Compose Configuration

Managed via Ansible role in `ansible/roles/it-tools/`.

```yaml
services:
  it-tools:
    image: corentinth/it-tools:latest
    container_name: it-tools
    restart: unless-stopped
    networks:
      - traefik-public
```
