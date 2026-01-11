# Hasura

Hasura fournit des APIs GraphQL instantanées sur vos bases de données.

## Quick Start

```bash
cd api-managment/hasura
docker compose up -d
```

## Ports

| Service | Port | Description |
|---------|------|-------------|
| Hasura Console | 8080 | GraphQL API & Console |

## Configuration

### Variables d'environnement

```bash
HASURA_GRAPHQL_DATABASE_URL=postgres://user:pass@host:5432/db
HASURA_GRAPHQL_ADMIN_SECRET=myadminsecret
HASURA_GRAPHQL_ENABLE_CONSOLE=true
```

## Liens

- [Documentation officielle](https://hasura.io/docs/)
