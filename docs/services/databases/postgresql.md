# PostgreSQL

Base de données relationnelle open-source.

## Quick Start

```bash
cd databases/postgres
docker compose up -d
```

## Accès

- **Port** : 5432
- **Client** : `psql -h localhost -U postgres`

## Configuration

### Variables d'environnement

```bash
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_DB=mydb
```

### compose.yml

```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: mydb
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

## Backup / Restore

```bash
# Backup
docker exec postgres pg_dump -U postgres mydb > backup.sql

# Restore
docker exec -i postgres psql -U postgres mydb < backup.sql
```

## Liens

- [Documentation officielle](https://www.postgresql.org/docs/)
