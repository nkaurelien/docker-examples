# TinyAuth ForwardAuth SSO Middleware

[TinyAuth](https://github.com/steveiliop56/tinyauth) is a lightweight authentication ForwardAuth middleware for Traefik edge reverse proxies.

---

## Service Overview

| Attribute | Details |
| :--- | :--- |
| **Service Name** | `tinyauth` |
| **Public URL** | `https://auth.kamitbrains.fr` |
| **Health Check** | `http://127.0.0.1:3000/api/health` |
| **Docker Image** | `ghcr.io/steveiliop56/tinyauth:v4` |
| **Traefik Middleware** | `tinyauth-auth@docker` |
| **ForwardAuth Address** | `http://tinyauth:3000/api/auth/traefik` |

---

## Traefik Integration

To protect any service with TinyAuth ForwardAuth SSO, add the middleware label:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.myservice.rule=Host(`myservice.kamitbrains.fr`)"
  - "traefik.http.routers.myservice.middlewares=tinyauth-auth@docker"
```

---

## Architecture & Docker Compose Configuration

Managed via Ansible role in `ansible/roles/tinyauth/`.

```yaml
services:
  tinyauth:
    image: ghcr.io/steveiliop56/tinyauth:v4
    container_name: tinyauth
    restart: unless-stopped
    environment:
      - SECRET=${TINYAUTH_SECRET}
      - USERS=admin@kamitbrains.fr:${TINYAUTH_ADMIN_PASSWORD}
      - APP_URL=https://auth.kamitbrains.fr
      - COOKIE_SECURE=true
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.tinyauth.rule=Host(`auth.kamitbrains.fr`)"
      - "traefik.http.routers.tinyauth.entrypoints=websecure"
      - "traefik.http.routers.tinyauth.tls.certresolver=letsencrypt"
      - "traefik.http.services.tinyauth.loadbalancer.server.port=3000"
      - "traefik.http.middlewares.tinyauth-auth.forwardauth.address=http://tinyauth:3000/api/auth/traefik"
      - "traefik.http.middlewares.tinyauth-auth.forwardauth.trustForwardHeader=true"
      - "traefik.http.middlewares.tinyauth-auth.forwardauth.authResponseHeaders=X-Auth-User"
```
