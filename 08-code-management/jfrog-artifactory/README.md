# JFrog Artifactory

This directory contains Docker Compose configurations for JFrog Artifactory.

## Editions

| Edition | Directory | Image | Description |
|---------|-----------|-------|-------------|
| **OSS** | [oss/](oss/) | `artifactory-oss` | Open Source - Generic artifact repository |
| **JCR** | [ce/](ce/) | `artifactory-jcr` | JFrog Container Registry - Docker/Helm optimized |
| **JCR + MinIO** | [minio/](minio/) | `artifactory-jcr` | JCR with S3-compatible storage (MinIO) |

## Choosing the Right Edition

### JCR vs OSS/CE - Key Differences

**JFrog Container Registry (JCR)** focuses exclusively on containers with a lighter architecture, while **OSS/CE** offers universal multi-format support.

| Aspect | JCR | Artifactory OSS/CE |
|--------|-----|-------------------|
| **Focus** | Docker/OCI images, Helm charts only | Universal (Maven, npm, Docker, etc.) |
| **Use case** | Container-only workflows, K8s/edge | Multi-format artifact management |
| **Resources** | 4GB RAM, 2 vCPU (lightweight) | 8GB RAM, 4 vCPU |
| **HA Support** | No (Enterprise only) | No |
| **Database** | PostgreSQL recommended | Derby (embedded) / PostgreSQL |
| **Status** | Actively maintained | OSS deprecated since 2021 |

### Recommendations

- **JCR**: Best for container-only workflows (Docker, Helm, OCI). Lightweight, ideal for K8s/edge deployments.
- **OSS**: Use only for testing/legacy. No security updates since 2021 - migrate to JCR or Pro.
- **Pro/Enterprise**: For production with HA, security scanning, and multi-format support.

> **Note**: For K8s/backend setups needing only containers, JCR is sufficient. For universal artifact management, consider Artifactory Pro.

## Quick Start

```bash
# Choose your edition
cd oss/  # or cd ce/

# Create environment file
cp .env.example .env

# Create required volumes
docker volume create artifactory_data
docker volume create postgres_data

# Start services
docker compose up -d
```

## Access

- **Artifactory UI**: http://localhost:8082
- **Artifactory API**: http://localhost:8081

Default credentials: `admin` / `password`

## Architecture

```
┌─────────────────┐     ┌─────────────────┐
│   Artifactory   │────▶│   PostgreSQL    │
│   :8081/:8082   │     │     :5432       │
└─────────────────┘     └─────────────────┘
```

## Configuration

Edit `.env` file to customize:

| Variable | Description | Default |
|----------|-------------|---------|
| `ARTIFACTORY_VERSION` | Artifactory version | `7.111.11` |
| `JF_ROUTER_ENTRYPOINTS_EXTERNALPORT` | External port | `8082` |
| `JF_SHARED_NODE_ID` | Node identifier | `artifactory-node-1` |

## Volumes

External volumes are used for data persistence:

- `artifactory_data` - Artifactory data and configuration
- `postgres_data` - PostgreSQL database

## Useful Commands

```bash
# View logs
docker compose logs -f artifactory

# Stop services
docker compose down

# Reset (WARNING: deletes data)
docker compose down -v
docker volume rm artifactory_data postgres_data
```

## Useful Links

- [JFrog Artifactory 5 Jenkins Integration (YouTube)](https://www.youtube.com/watch?v=OS6TycMnfiA&t=338s)
- [JFrog GitLab Templates](https://github.com/jfrog/gitlab-templates)
