# Traefik - Cloud Native Edge Router

Traefik is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy.

## Quick Start

```bash
# Start Traefik
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f traefik
```

## Access Points

| Service | URL | Description |
|---------|-----|-------------|
| Dashboard | http://localhost:8080 | Traefik dashboard |
| Dashboard (via router) | http://traefik.apps.local | Dashboard with host routing |
| Whoami | http://whoami.apps.local | Test service |

## Local DNS Setup

Add these entries to your hosts file or use `hostctl`:

```bash
# Using hostctl
hostctl add domains apps traefik.apps.local whoami.apps.local

# Or manually add to /etc/hosts
127.0.0.1 traefik.apps.local whoami.apps.local
```

## Configuration

### Docker Labels

Services are exposed via Docker labels:

```yaml
services:
  my-service:
    image: my-image
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.my-service.rule=Host(`my-service.apps.local`)"
      - "traefik.http.routers.my-service.entrypoints=web"
      - "traefik.http.services.my-service.loadbalancer.server.port=8080"
```

### Path-based Routing

```yaml
labels:
  - "traefik.http.routers.api.rule=Host(`api.apps.local`) && PathPrefix(`/v1`)"
```

### Using Middlewares

```yaml
labels:
  - "traefik.http.routers.secure.middlewares=basic-auth@file,security-headers@file"
```

### Available Middlewares (in config/dynamic/middlewares.yml)

- `rate-limit@file` - Rate limiting (100 req/s average)
- `basic-auth@file` - Basic authentication (admin:password)
- `security-headers@file` - Security headers
- `compress@file` - Gzip compression
- `strip-api-prefix@file` - Strip /api prefix
- `retry@file` - Retry failed requests

## Enable HTTPS with Let's Encrypt

Use `compose.letsencrypt.yml` for production with automatic HTTPS:

```bash
# Copy environment file
cp .env.example .env
# Edit with your domain and email
nano .env

# Create acme.json with correct permissions
touch letsencrypt/acme.json
chmod 600 letsencrypt/acme.json

# Start with Let's Encrypt configuration
docker compose -f compose.letsencrypt.yml up -d
```

For detailed documentation on Let's Encrypt and ACME, see [docs/letsencrypt-acme.md](docs/letsencrypt-acme.md).

### Quick Labels for HTTPS

```yaml
labels:
  - "traefik.http.routers.my-service.tls.certresolver=letsencrypt"
  - "traefik.http.routers.my-service.entrypoints=websecure"
```

## Network Integration

Other services can join the Traefik network:

```yaml
services:
  my-app:
    networks:
      - traefik-public

networks:
  traefik-public:
    external: true
```

## Commands

```bash
# Restart Traefik
docker compose restart traefik

# View real-time logs
docker compose logs -f traefik

# Check configuration
docker exec traefik traefik healthcheck

# Stop all services
docker compose down

# Stop and remove volumes
docker compose down -v
```

## Troubleshooting

### Service not accessible
1. Verify the service has `traefik.enable=true`
2. Check the service is on the `traefik-public` network
3. Verify DNS/hosts configuration
4. Check dashboard for router/service status

### Certificate issues
1. Ensure port 80 is accessible for HTTP challenge
2. Check `docker compose logs traefik` for ACME errors
3. Verify domain points to your server

### Dashboard not loading
- Ensure port 8080 is not in use: `lsof -i :8080`
- Check Traefik container status: `docker compose ps`

## Useful Links

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Traefik Docker Tutorial: bien débuter avec ce reverse proxy HTTPS moderne (YouTube)](https://www.youtube.com/watch?v=Ct5EBiSuy5U)
- [Lego DNS Providers](https://go-acme.github.io/lego/dns/) - Liste des fournisseurs DNS supportés pour le challenge ACME
