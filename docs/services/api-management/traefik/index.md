# Traefik

Traefik est un reverse proxy et load balancer moderne avec auto-discovery Docker.

## Quick Start

```bash
cd api-managment/traefik
docker compose up -d
```

## Accès

- **Dashboard**: http://localhost:8080
- **HTTP**: http://localhost:80
- **HTTPS**: https://localhost:443 (si configuré)

## Fichiers Disponibles

| Fichier | Description |
|---------|-------------|
| `compose.yml` | Configuration de base |
| `compose.socket-proxy.yml` | Avec docker-socket-proxy (sécurisé) |
| `compose.letsencrypt.yml` | Avec certificats Let's Encrypt |
| `compose.letsencrypt.socket-proxy.yml` | Let's Encrypt + socket-proxy |
| `compose.tinyauth.yml` | Avec authentification TinyAuth |
| `compose.tinyauth.socket-proxy.yml` | TinyAuth + socket-proxy |

## Variantes

### Standard

```bash
docker compose up -d
```

### Avec Socket Proxy (Recommandé)

```bash
docker compose -f compose.socket-proxy.yml up -d
```

### Avec Let's Encrypt

```bash
# Configurer .env
cp .env.example .env
# Éditer DOMAIN et ACME_EMAIL

docker compose -f compose.letsencrypt.yml up -d
```

### Avec TinyAuth

```bash
docker compose -f compose.tinyauth.yml up -d
# Login: user / password
```

## Configuration

```env
# .env
DOMAIN=apps.local
ACME_EMAIL=admin@example.com

# TinyAuth (optionnel)
TINYAUTH_USERS=user:$2a$10$...
TINYAUTH_SECRET=change-me
```

## Labels Docker

Exposer un service via Traefik :

```yaml
services:
  myapp:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.myapp.rule=Host(`myapp.${DOMAIN}`)"
      - "traefik.http.routers.myapp.entrypoints=web"
      - "traefik.http.services.myapp.loadbalancer.server.port=8080"
```

## Voir Aussi

- [TinyAuth Integration](tinyauth.md)
- [Let's Encrypt](letsencrypt.md)
- [Socket Proxy](socket-proxy.md)
- [Socket Proxy Permissions](../../../reference/socket-proxy-permissions.md)
