# JFrog Container Registry with MinIO

JFrog Container Registry with MinIO available for future S3-compatible storage integration.

## Features

- Docker Registry v2 compatible
- Helm Chart repository
- OCI artifact support
- MinIO ready for S3 storage (requires Pro/Enterprise license)

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Artifactory   │────▶│   PostgreSQL    │     │     MinIO       │
│   :8084/:8083   │     │     :5433       │     │  :9000/:9001    │
└─────────────────┘                             └─────────────────┘
```

## Quick Start

```bash
# Create environment file
cp .env.example .env

# Start services
docker compose up -d
```

## Access

| Service | URL | Credentials |
|---------|-----|-------------|
| Artifactory UI | http://localhost:8083 | admin / password |
| MinIO Console | http://localhost:9001 | minioadmin / minioadmin123 |
| MinIO API | http://localhost:9000 | - |

## Services

| Service | Container | Port | Description |
|---------|-----------|------|-------------|
| Artifactory | artifactory-minio-jcr | 8084, 8083 | Container registry |
| PostgreSQL | artifactory-minio-postgresql | 5433 | Database |
| MinIO | artifactory-minio | 9000, 9001 | S3 storage (standby) |

## S3 Storage Configuration (Pro/Enterprise Only)

S3 storage with MinIO requires Artifactory Pro or Enterprise license. The `config/binarystore.xml` file is provided for reference.

### Key Parameters for MinIO

```xml
<provider id="s3-storage-v3" type="s3-storage-v3">
    <endpoint>http://minio:9000/</endpoint>
    <bucketName>artifactory</bucketName>
    <region>us-east-1</region>
    <identity>minioadmin</identity>
    <credential>minioadmin123</credential>
    <useHttp>true</useHttp>              <!-- Required for non-HTTPS -->
    <pathStyleAccess>true</pathStyleAccess>  <!-- Required for MinIO -->
    <useInstanceCredentials>false</useInstanceCredentials>
    <testConnection>false</testConnection>
</provider>
```

### Important Notes

- `useHttp>true` - Forces HTTP instead of HTTPS (default is HTTPS)
- `pathStyleAccess>true` - Uses path-style URLs (bucket in path, not subdomain)
- `useInstanceCredentials>false` - Disables AWS instance metadata credentials

### Enabling S3 Storage

1. Obtain Artifactory Pro/Enterprise license
2. Uncomment the binarystore.xml volume mount in compose.yml:
   ```yaml
   - ./config/binarystore.xml:/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml:ro
   ```
3. Restart: `docker compose down -v && docker compose up -d`

## Configuration

Edit `.env` file to customize:

| Variable | Description | Default |
|----------|-------------|---------|
| `ARTIFACTORY_VERSION` | Artifactory version | `7.111.11` |
| `JF_ROUTER_ENTRYPOINTS_EXTERNALPORT` | External port | `8083` |
| `MINIO_ACCESS_KEY` | MinIO access key | `minioadmin` |
| `MINIO_SECRET_KEY` | MinIO secret key | `minioadmin123` |
| `S3_BUCKET_NAME` | S3 bucket name | `artifactory` |

## Useful Commands

```bash
# View logs
docker compose logs -f artifactory
docker compose logs -f minio

# Stop services
docker compose down

# Reset all data
docker compose down -v
```

## Notes

- This setup uses non-external volumes for easier cleanup
- Port 8083/8084 used to avoid conflict with other Artifactory instances
- PostgreSQL uses port 5433 to avoid conflicts
- MinIO is running but not connected to Artifactory by default (JCR limitation)
