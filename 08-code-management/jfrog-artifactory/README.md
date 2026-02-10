# JFrog Artifactory

Docker Compose configurations for JFrog Artifactory.

## Editions

| Edition     | Directory        | Image             | Description        |
|-------------|------------------|-------------------|--------------------|
| **OSS**     | [oss/](oss/)     | `artifactory-oss` | Generic artifacts  |
| **JCR**     | [ce/](ce/)       | `artifactory-jcr` | Docker/Helm        |
| **JCR+MinIO** | [minio/](minio/) | `artifactory-jcr` | JCR + S3 (MinIO) |

## Choosing the Right Edition

### JCR vs OSS/CE - Key Differences

**JFrog Container Registry (JCR)** focuses exclusively on
containers with a lighter architecture, while **OSS/CE** offers
universal multi-format support.

| Aspect       | JCR                    | OSS/CE                  |
|--------------|------------------------|-------------------------|
| **Focus**    | Docker/OCI, Helm only  | Maven, npm, Docker, etc |
| **Use case** | Container-only, K8s    | Multi-format artifacts  |
| **Resources**| 4GB RAM, 2 vCPU        | 8GB RAM, 4 vCPU         |
| **HA**       | No (Enterprise only)   | No                      |
| **Database** | PostgreSQL recommended | Derby / PostgreSQL      |
| **Status**   | Actively maintained    | Deprecated since 2021   |

### Recommendations

- **JCR**: Best for container-only workflows (Docker, Helm,
  OCI). Lightweight, ideal for K8s/edge deployments.
- **OSS**: Use only for testing/legacy. No security updates
  since 2021 - migrate to JCR or Pro.
- **Pro/Enterprise**: For production with HA, security
  scanning, and multi-format support.

> **Note**: For K8s/backend setups needing only containers,
> JCR is sufficient. For universal artifact management,
> consider Artifactory Pro.

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

- **Artifactory UI**: <http://localhost:8082>
- **Artifactory API**: <http://localhost:8081>

Default credentials: `admin` / `password`

## Architecture

```text
┌─────────────────┐     ┌─────────────────┐
│   Artifactory   │────▶│   PostgreSQL    │
│   :8081/:8082   │     │     :5432       │
└─────────────────┘     └─────────────────┘
```

## Production Setup (Nginx + SSL)

The `ce/` directory includes a production-ready Nginx reverse
proxy with SSL/TLS, which is required for using JFrog as a
Docker registry (`docker login`/`push`/`pull` require HTTPS).

```bash
cd ce/

# Generate SSL certs with mkcert
make ssl

# Start Artifactory + Nginx
make up

# Check health
make health

# Login and push
make login TOKEN=<your-token>
make push IMAGE=myapp TAG=v1.0
```

See [ce/README.md](ce/README.md) for full documentation
including:

- Nginx configuration details
- SSL/TLS setup with mkcert
- Docker registry login/push/pull workflow
- JFrog API reference
- Troubleshooting guide

### Common Pitfalls

| Problem                   | Quick Fix                       |
|---------------------------|---------------------------------|
| Docker falls back to HTTP | Use hostname `registry.localhost` |
| Push: "repo not found"   | Prefix with `docker-local/`     |
| SSL errors (`x509`)      | Use `mkcert`, restart Docker    |
| Token redirect wrong port | Set `urlBase` via JFrog API     |

## Configuration

Edit `.env` file to customize:

| Variable                 | Description | Default        |
|--------------------------|-------------|----------------|
| `ARTIFACTORY_VERSION`   | Version     | `7.111.11`     |
| `JF_ROUTER_..._PORT`    | External port | `8082`       |
| `JF_SHARED_NODE_ID`     | Node ID     | `...-node-1`  |

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

- [JFrog Artifactory Jenkins Integration (YouTube)](https://www.youtube.com/watch?v=OS6TycMnfiA&t=338s)
- [JFrog GitLab Templates](https://github.com/jfrog/gitlab-templates)
