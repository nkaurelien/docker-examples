# JFrog Container Registry (JCR)

JFrog Container Registry - optimized for Docker and Helm chart management.

## Features

- Docker Registry v2 compatible
- Helm Chart repository
- OCI artifact support
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

## Docker Registry Usage

```bash
# Login to registry
docker login localhost:8082

# Tag and push image
docker tag myimage:latest localhost:8082/docker-local/myimage:latest
docker push localhost:8082/docker-local/myimage:latest

# Pull image
docker pull localhost:8082/docker-local/myimage:latest
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| Artifactory JCR | 8081, 8082 | Container registry |
| PostgreSQL | 5432 | Database |

## Configuration

Copy `.env.example` to `.env` and adjust values as needed.

## Persistence

Data is stored in external Docker volumes:
- `artifactory_data` - Registry data and config
- `postgres_data` - Database files
