# API Management

Solutions de reverse proxy et API gateway.

## Services Disponibles

### [Traefik](traefik/index.md)

Reverse proxy moderne avec auto-discovery Docker :

```bash
cd api-managment/traefik
docker compose up -d
# http://localhost:8080 (dashboard)
```

### [Kong](kong.md)

API Gateway enterprise :

```bash
cd api-managment/kong
docker compose up -d
```

### [Hasura](hasura.md)

GraphQL Engine instant :

```bash
cd api-managment/hasura
docker compose up -d
```

## Comparatif

| Feature | Traefik | Kong | Hasura |
|---------|---------|------|--------|
| Type | Reverse Proxy | API Gateway | GraphQL Engine |
| Auto-discovery | ✅ Docker | ❌ | ❌ |
| Let's Encrypt | ✅ Built-in | Plugin | ❌ |
| Dashboard | ✅ | ✅ | ✅ |
| Middlewares | ✅ | ✅ Plugins | ❌ |
| Load Balancing | ✅ | ✅ | ❌ |
