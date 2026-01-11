# Kong

Kong est un API Gateway cloud-native performant et extensible.

## Quick Start

```bash
cd api-managment/kong
docker compose up -d
```

## Ports

| Service | Port | Description |
|---------|------|-------------|
| Kong Proxy | 8000 | HTTP traffic |
| Kong Proxy SSL | 8443 | HTTPS traffic |
| Kong Admin | 8001 | Admin API |
| Kong Manager | 8002 | Admin UI |

## Configuration

### Variables d'environnement

```bash
KONG_DATABASE=postgres
KONG_PG_HOST=kong-database
KONG_PG_USER=kong
KONG_PG_PASSWORD=kongpass
```

## Liens

- [Documentation officielle](https://docs.konghq.com/)
- [Kong Hub (Plugins)](https://docs.konghq.com/hub/)
