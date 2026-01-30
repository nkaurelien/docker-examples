# JFrog Artifactory OSS

Open Source edition of JFrog Artifactory - a universal artifact repository manager.

## Features

- Generic artifact repository (Maven, npm, PyPI, etc.)
- Local, remote, and virtual repositories
- REST API
- Web UI

## Quick Start

```bash
# Create environment file
cp .env.example .env

# Create required volumes
docker volume create artifactory_data
docker volume create postgres_data

# Start services
docker compose up -d
```

## Access

- **UI**: http://localhost:8082
- **API**: http://localhost:8081

Default credentials: `admin` / `password`

## Services

| Service | Port | Description |
|---------|------|-------------|
| Artifactory | 8081, 8082 | Artifact repository |
| PostgreSQL | 5432 | Database |

## Configuration

Copy `.env.example` to `.env` and adjust values as needed.

## Persistence

Data is stored in external Docker volumes:
- `artifactory_data` - Artifactory files and config
- `postgres_data` - Database files
