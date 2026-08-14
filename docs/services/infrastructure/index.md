# Infrastructure

Core infrastructure services for networking, reverse proxy, SSL/TLS management, and DNS.

## Services

| Service | Description | Path |
|---------|-------------|------|
| [Traefik](../api-management/traefik/index.md) | Modern reverse proxy and load balancer | `compose/01-infrastructure/traefik/` |
| [Bind9](bind9.md) | DNS server for local domain resolution | `compose/01-infrastructure/bind9/` |
| [Nginx + Certbot](../api-management/nginx-certbot.md) | Nginx with Let's Encrypt SSL | `compose/01-infrastructure/nginx-certbot/` |

## Network Architecture

```mermaid
graph LR
    Client -->|DNS Query| Bind9
    Bind9 -->|Resolve| Traefik
    Traefik -->|Route| Services
```

## Common Configuration

All infrastructure services share:

- **Domain**: `apps.local` (configurable via `$DOMAIN` env var)
- **Network**: `traefik-public` for inter-service communication
- **DNS**: Bind9 resolves `*.apps.local` to Docker host
