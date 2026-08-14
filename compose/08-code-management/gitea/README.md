# Gitea - Self-Hosted Git Service

Gitea is a painless, self-hosted, all-in-one software development service. It includes Git hosting, code review, team collaboration, package registry, and CI/CD. Written in Go, it's lightweight, fast, and runs on any platform.

## Features

- **Git Hosting**: Repository management, branches, tags, releases
- **Code Review**: Pull requests with inline comments and approvals
- **Issue Tracking**: Issues, milestones, labels, and project boards
- **CI/CD**: Gitea Actions (GitHub Actions compatible)
- **Package Registry**: Docker, npm, Maven, PyPI, and more
- **Wiki**: Built-in documentation wiki per repository
- **Organizations**: Team management with fine-grained permissions
- **Webhooks**: Integration with external services
- **OAuth2/LDAP**: Multiple authentication backends
- **Mirror Repositories**: Mirror from/to GitHub, GitLab, etc.
- **Lightweight**: Minimal resource requirements (~100MB RAM)
- **Cross-Platform**: Linux, macOS, Windows, ARM

## Quick Start

```bash
docker compose up -d
```

Access Gitea at: http://localhost:3000

## Docker Compose Setup

### Basic (SQLite)

```yaml
# compose.yml
services:
  gitea:
    image: docker.gitea.com/gitea:latest
    container_name: gitea
    restart: unless-stopped
    ports:
      - "3000:3000"
      - "2222:22"
    volumes:
      - gitea-data:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    environment:
      - USER_UID=1000
      - USER_GID=1000

volumes:
  gitea-data:
```

### Production (PostgreSQL)

```yaml
# compose.yml
services:
  gitea:
    image: docker.gitea.com/gitea:latest
    container_name: gitea
    restart: unless-stopped
    ports:
      - "3000:3000"
      - "2222:22"
    volumes:
      - gitea-data:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    environment:
      - USER_UID=1000
      - USER_GID=1000
      - GITEA__database__DB_TYPE=postgres
      - GITEA__database__HOST=gitea-db:5432
      - GITEA__database__NAME=gitea
      - GITEA__database__USER=gitea
      - GITEA__database__PASSWD=${DB_PASSWORD:-gitea}
      - GITEA__server__ROOT_URL=${ROOT_URL:-http://localhost:3000}
      - GITEA__server__SSH_DOMAIN=${SSH_DOMAIN:-localhost}
      - GITEA__server__SSH_PORT=2222
      - GITEA__mailer__ENABLED=false
    depends_on:
      gitea-db:
        condition: service_healthy
    networks:
      - gitea-network
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.gitea.rule=Host(`git.apps.local`)"
      - "traefik.http.routers.gitea.entrypoints=websecure"
      - "traefik.http.routers.gitea.tls=true"
      - "traefik.http.services.gitea.loadbalancer.server.port=3000"

  gitea-db:
    image: postgres:16-alpine
    container_name: gitea-db
    restart: unless-stopped
    volumes:
      - gitea-postgres:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=gitea
      - POSTGRES_USER=gitea
      - POSTGRES_PASSWORD=${DB_PASSWORD:-gitea}
    networks:
      - gitea-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U gitea -d gitea"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  gitea-data:
  gitea-postgres:

networks:
  gitea-network:
  traefik-public:
    external: true
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `USER_UID` | `1000` | UID of the git user |
| `USER_GID` | `1000` | GID of the git user |
| `GITEA__server__ROOT_URL` | - | Public URL of Gitea |
| `GITEA__server__SSH_DOMAIN` | - | Domain for SSH access |
| `GITEA__server__SSH_PORT` | `22` | SSH port |
| `GITEA__database__DB_TYPE` | `sqlite3` | Database type |
| `GITEA__database__HOST` | - | Database host:port |
| `GITEA__database__NAME` | - | Database name |
| `GITEA__database__USER` | - | Database user |
| `GITEA__database__PASSWD` | - | Database password |

### Generate Secrets

```bash
# Generate SECRET_KEY
docker run -it --rm docker.gitea.com/gitea:latest gitea generate secret SECRET_KEY

# Generate INTERNAL_TOKEN
docker run -it --rm docker.gitea.com/gitea:latest gitea generate secret INTERNAL_TOKEN

# Generate LFS_JWT_SECRET
docker run -it --rm docker.gitea.com/gitea:latest gitea generate secret LFS_JWT_SECRET
```

### app.ini Configuration

For advanced configuration, mount a custom `app.ini`:

```yaml
volumes:
  - ./config/app.ini:/data/gitea/conf/app.ini
```

Example `app.ini`:

```ini
[server]
ROOT_URL = https://git.apps.local
SSH_DOMAIN = git.apps.local
SSH_PORT = 2222
LFS_START_SERVER = true

[database]
DB_TYPE = postgres
HOST = gitea-db:5432
NAME = gitea
USER = gitea
PASSWD = gitea

[security]
SECRET_KEY = your-secret-key-here
INTERNAL_TOKEN = your-internal-token-here

[service]
DISABLE_REGISTRATION = false
REQUIRE_SIGNIN_VIEW = false
DEFAULT_KEEP_EMAIL_PRIVATE = true

[mailer]
ENABLED = true
PROTOCOL = smtp
SMTP_ADDR = smtp.example.com
SMTP_PORT = 587
USER = gitea@example.com
PASSWD = your-smtp-password
FROM = gitea@example.com

[openid]
ENABLE_OPENID_SIGNIN = true
ENABLE_OPENID_SIGNUP = true

[oauth2_client]
ENABLE_AUTO_REGISTRATION = true
USERNAME = nickname

[actions]
ENABLED = true
DEFAULT_ACTIONS_URL = github
```

## Gitea Actions (CI/CD)

Gitea Actions is compatible with GitHub Actions workflows. It uses [act_runner](https://gitea.com/gitea/act_runner) to execute jobs.

### Enable Actions

Actions are enabled by default in this setup. To verify:

```yaml
environment:
  - GITEA__actions__ENABLED=true
  - GITEA__actions__DEFAULT_ACTIONS_URL=github
```

### Start the Runner

The runner is included in the compose file with a profile:

```bash
# Start Gitea with the runner
docker compose --profile runner up -d
```

### Get Registration Token

Before starting the runner, you need a registration token:

```bash
# Method 1: Via Gitea CLI
docker exec gitea gitea actions generate-runner-token

# Method 2: Via Gitea UI
# Go to: Site Administration > Actions > Runners > Create new runner
```

Add the token to your `.env` file:

```bash
RUNNER_TOKEN=your-token-here
```

### Runner Configuration

The runner supports custom configuration via `runner/config.yaml`:

```yaml
runner:
  # Max concurrent jobs
  capacity: 1
  # Job timeout
  timeout: 3h
  # Runner labels
  labels:
    - "ubuntu-latest:docker://node:20-bookworm"
    - "ubuntu-22.04:docker://node:20-bookworm"
```

### Runner Labels

Labels define which Docker images to use for each workflow `runs-on` value:

| Label | Docker Image | Use Case |
|-------|--------------|----------|
| `ubuntu-latest` | `node:20-bookworm` | Node.js projects |
| `ubuntu-22.04` | `node:20-bookworm` | Specific Ubuntu version |
| `ubuntu-20.04` | `node:18-bullseye` | Older Node.js |

Custom labels in `.env`:

```bash
RUNNER_LABELS=ubuntu-latest:docker://node:20-bookworm,python:docker://python:3.11,golang:docker://golang:1.21
```

### Manual Registration (Alternative)

```bash
# Interactive registration
docker exec -it gitea-runner act_runner register

# Non-interactive registration
docker exec gitea-runner act_runner register \
  --instance http://gitea:3000 \
  --token <your-token> \
  --no-interactive

# Start daemon
docker exec gitea-runner act_runner daemon
```

### Verify Runner Status

```bash
# Check runner logs
docker logs -f gitea-runner

# List registered runners in Gitea
# Go to: Site Administration > Actions > Runners
```

### Register Runner (Legacy)

```bash
# Get registration token from Gitea UI:
# Site Administration > Actions > Runners > Create new runner

# Or generate token via API
docker exec gitea gitea actions generate-runner-token
```

### Example Workflow

```yaml
# .gitea/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: make build
      - name: Test
        run: make test
```

## SSH Configuration

### Using Non-Standard Port

```yaml
environment:
  - GITEA__server__SSH_PORT=2222
  - GITEA__server__SSH_DOMAIN=git.apps.local
```

Configure SSH client:

```bash
# ~/.ssh/config
Host git.apps.local
    HostName git.apps.local
    Port 2222
    User git
```

### SSH Passthrough (Optional)

For native port 22, configure SSH passthrough on the host.

## Migration from Other Platforms

Gitea supports migration from:
- GitHub
- GitLab
- Bitbucket
- Gogs
- OneDev
- Gitea (other instances)

```bash
# Via UI: New Migration > Select source
# Or via API
```

## Backup & Restore

### Backup

```bash
# Full backup
docker exec -u git gitea gitea dump -c /data/gitea/conf/app.ini

# Backup data volume
docker run --rm \
  -v gitea-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/gitea-backup.tar.gz -C /data .
```

### Restore

```bash
# Restore from dump
docker exec gitea unzip gitea-dump-*.zip -d /tmp/restore
docker exec gitea gitea restore --from /tmp/restore

# Restore volume
docker run --rm \
  -v gitea-data:/data \
  -v $(pwd):/backup \
  alpine sh -c "rm -rf /data/* && tar xzf /backup/gitea-backup.tar.gz -C /data"
```

## Troubleshooting

```bash
# View logs
docker logs -f gitea

# Access shell
docker exec -it gitea /bin/bash

# Check configuration
docker exec gitea gitea doctor check

# Regenerate hooks
docker exec -u git gitea gitea admin regenerate hooks

# Reset admin password
docker exec -u git gitea gitea admin user change-password --username admin --password newpassword
```

### Common Issues

**Permission denied on volumes**
```bash
# Ensure correct ownership
sudo chown -R 1000:1000 /path/to/gitea/data
```

**SSH not working**
- Check `SSH_PORT` and `SSH_DOMAIN` settings
- Ensure port is exposed and not blocked by firewall
- Verify SSH key is added to Gitea

**Actions not running**
- Ensure `GITEA__actions__ENABLED=true`
- Register at least one runner
- Check runner logs: `docker logs gitea-runner`

## Documentation

- [Official Website](https://about.gitea.com/)
- [Documentation](https://docs.gitea.com/)
- [GitHub Repository](https://github.com/go-gitea/gitea)
- [Docker Installation](https://docs.gitea.com/installation/install-with-docker)
- [Configuration Cheat Sheet](https://docs.gitea.com/administration/config-cheat-sheet)
- [Gitea Actions](https://docs.gitea.com/usage/actions/overview)
