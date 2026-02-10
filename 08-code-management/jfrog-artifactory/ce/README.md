# JFrog Container Registry (JCR)

JFrog Container Registry - optimized for Docker and Helm chart
management.

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

- **UI**: <http://localhost:8082>
- **API**: <http://localhost:8081>

Default credentials: `admin` / `password`

## Services

| Service         | Port       | Description        |
|-----------------|------------|--------------------|
| Artifactory JCR | 8081, 8082 | Container registry |
| PostgreSQL      | 5432       | Database           |

## Configuration

Copy `.env.example` to `.env` and adjust values as needed.

## Persistence

Data is stored in external Docker volumes:

- `artifactory_data` - Registry data and config
- `postgres_data` - Database files

---

## Nginx Reverse Proxy

The `compose.nginx.yml` overlay adds an Nginx reverse proxy with
SSL termination in front of Artifactory. This is the recommended
setup for using JFrog as a Docker registry since Docker requires
HTTPS for `docker login`/`push`/`pull`.

### Architecture

```text
               ┌────────┐  ┌───────────┐  ┌──────────┐
docker push ─▶ │ Nginx  │─▶│Artifactory│─▶│PostgreSQL│
(HTTPS :443)   │SSL+prxy│  │:8082/:8081│  │  :5432   │
               └────────┘  └───────────┘  └──────────┘
```

### Setup

```bash
# 1. Generate SSL certificates
make ssl
# Or: bash ssl/generate-certs.sh

# 2. Add DNS entry
echo "127.0.0.1 registry.localhost" \
  | sudo tee -a /etc/hosts

# 3. Start with Nginx
make up
# Or:
# docker compose -f compose.yml \
#   -f compose.nginx.yml up -d

# 4. Wait for health check
make health
```

### Key Nginx settings

| Setting                     | Value  | Why                    |
|-----------------------------|--------|------------------------|
| `client_max_body_size`      | `500M` | Large Docker layers    |
| `proxy_request_buffering`   | `off`  | Stream uploads         |
| `chunked_transfer_encoding` | `on`   | Docker V2 chunked API  |
| `proxy_buffering`           | `off`  | No response buffering  |
| `proxy_read_timeout`        | `300s` | Slow layer pushes      |

---

## SSL/TLS with mkcert

[mkcert](https://github.com/FiloSottile/mkcert) generates
locally-trusted SSL certificates. Unlike self-signed certs
(`openssl`), mkcert creates a local CA that is automatically
trusted by browsers and Docker.

```bash
# Generate certs (installs CA if needed)
bash ssl/generate-certs.sh

# Or with a custom domain
bash ssl/generate-certs.sh myregistry.local
```

Certs are written to `ssl/certs/`. After generating:

1. **Restart Docker Desktop** so it picks up the new CA
2. Verify:
   `curl https://registry.localhost/router/api/v1/system/health`

---

## Docker Registry Usage

### Login

```bash
# Get an Identity Token from the JFrog UI:
#   Administration > Identity and Access
#   > User Management > Generate Identity Token

echo "<token>" | docker login \
  https://registry.localhost \
  -u admin --password-stdin
```

### Tag, Push, Pull

```bash
# Tag ("docker-local" is the JFrog repo key)
docker tag myapp:latest \
  registry.localhost/docker-local/myapp:v1.0

# Push
docker push \
  registry.localhost/docker-local/myapp:v1.0

# Pull
docker pull \
  registry.localhost/docker-local/myapp:v1.0
```

### Verify

```bash
# List all repositories
curl -sk https://registry.localhost/v2/_catalog

# List tags for an image
curl -sk \
  https://registry.localhost/v2/docker-local/myapp/tags/list
```

### Using the Makefile

```bash
make login TOKEN=<your-token>
make push IMAGE=myapp TAG=v1.0
make pull IMAGE=myapp TAG=v1.0
make catalog
make tags IMAGE=myapp
make health
```

Run `make help` to see all targets.

---

## JFrog API Reference

### Docker V2 endpoints (no auth required)

- `GET /v2/_catalog` - List Docker repositories
- `GET /v2/<repo>/<image>/tags/list` - List tags

### Artifactory endpoints

- `GET /artifactory/api/system/ping` - Ping (no auth)
- `GET /router/api/v1/system/health` - Health (no auth)
- `GET /artifactory/api/repositories` - List repos (auth)
- `PUT /artifactory/api/repositories/<key>` - Create (Pro)
- `POST /artifactory/ui/api/v1/ui/artifactoryui`
  Set `urlBase` (CE workaround, auth required)

### Setting urlBase (important for Docker auth)

JFrog CE doesn't expose `urlBase` in the UI. Without it,
Docker token-service redirects may point to the wrong port.
Set it via API:

```bash
curl -X POST \
  https://registry.localhost/artifactory/ui/api/v1/ui/artifactoryui \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"urlBase": "https://registry.localhost"}'
```

---

## Troubleshooting

### Docker uses HTTP instead of HTTPS

**Cause**: Registry resolves to `127.0.0.1` (Docker treats
localhost as insecure).
**Fix**: Use a real hostname like `registry.localhost` and add
it to `/etc/hosts`.

### `Repository 'X' not found` on push

**Cause**: Wrong path prefix.
**Fix**: Use `docker-local` (the JFrog repo key) as the first
path segment: `registry.localhost/docker-local/myimage`.

### `x509: certificate signed by unknown authority`

**Cause**: Docker Desktop doesn't trust the CA.
**Fix**: Run `mkcert -install` and **restart Docker Desktop**.

### `MOZILLA_PKIX_ERROR_CA_CERT_USED_AS_END_ENTITY`

**Cause**: Self-signed cert without a CA chain.
**Fix**: Use `mkcert` instead of `openssl` to generate certs.

### Token service redirects to wrong port

**Cause**: `urlBase` not configured in JFrog.
**Fix**: Set `urlBase` via the API (see above).

### `401 Unauthorized` on API calls

**Cause**: Default password changed or expired.
**Fix**: Use an Identity Token from JFrog UI.

### `413 Request Entity Too Large`

**Cause**: Nginx body size limit.
**Fix**: Set `client_max_body_size 500M` in Nginx config.

### Push hangs or times out

**Cause**: Proxy buffering enabled.
**Fix**: Set `proxy_request_buffering off` and
`proxy_buffering off`.
