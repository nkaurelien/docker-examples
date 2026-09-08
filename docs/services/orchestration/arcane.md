---
tags: arcane, docker-manager, orchestration
---

# Arcane

Arcane is an open-source, modern self-hosted dashboard for managing Docker containers and stacks. It is designed to be lightweight, secure, and easy to use, providing a clean user interface for managing your self-hosted infrastructure.

This configuration deploys Arcane Manager securely using a **Docker Socket Proxy** to prevent exposing the host's `/var/run/docker.sock` directly to the Arcane container.

## Features

- **Stack Management**: Manage your Docker Compose stacks directly from the UI.
- **Container Control**: Start, stop, restart, and monitor containers.
- **Resource Monitoring**: Track CPU, memory, and network usage.
- **Security First**: Runs using `docker-socket-proxy` to limit Docker API access.
- **Traefik Integration**: Out-of-the-box labels for Traefik reverse proxy routing.
- **Clean UI**: Beautiful and user-friendly dashboard interface.

## Quick Start

```bash
cd compose/02-container-orchestration/arcane
cp .env.example .env
# Edit .env and set ENCRYPTION_KEY and JWT_SECRET
docker compose up -d
```

Access at: `http://localhost:3552` or `http://arcane.apps.local` (via Traefik)

## Configuration & Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ARCANE_PORT` | `3552` | Port on the host to access Arcane UI |
| `PROJECTS_DIR` | `./projects` | Directory on the host where project stacks are stored |
| `TEMPLATES_DIR` | `./templates` | Directory on the host where custom template definitions are stored |
| `BUILDS_DIR` | `./builds` | Build Workspace directory for Dockerfiles and build contexts |
| `BACKUPS_DIR` | `./backups` | Directory to store exported volume backups |
| `ENCRYPTION_KEY` | - | 32-byte hex key for database encryption (required) |
| `JWT_SECRET` | - | Secret key for JWT token signatures (required) |
| `PUID` | `1000` | User ID for container file permissions |
| `PGID` | `1000` | Group ID for container file permissions |
| `TZ` | `Europe/Paris` | Container timezone |

## Storage Architecture & Dedicated Folders

Arcane relies on specific folder structures for its operational workspaces:

- **Data Volume (`arcane-data:/app/data`)**: Stores Arcane's primary SQLite database (`arcane.db`) and application state.
- **Projects Directory (`/app/data/projects`)**: Host directory where deployed stacks and compose files are saved (mapped to `${PROJECTS_DIR:-./projects}`).
- **Templates Directory (`/app/data/templates`)**: Host directory for custom local templates (mapped to `${TEMPLATES_DIR:-./templates}`).
- **Build Workspace (`/builds`)**: Dedicated directory for Dockerfiles and build contexts (mapped to `${BUILDS_DIR:-./builds}`).
- **Volume Backups (`/backups`)**: Dedicated directory to export volume backups in a predictable host location (mapped to `${BACKUPS_DIR:-./backups}`).

### Non-Root User Permissions

Official Arcane manager images start as `root` for startup preparation, then drop to a non-root runtime user by default.
- Set `PUID` and `PGID` in `.env` if you want Arcane-created files on mounted volumes to match your host user permissions.
- If `PUID`/`PGID` are omitted, Arcane falls back to its built-in non-root user (`65532:65532`).

## Security Hardening (Docker Socket Proxy)

Arcane runs behind `tecnativa/docker-socket-proxy` to avoid mounting `/var/run/docker.sock` directly into the container:
- Enables necessary API flags: `EVENTS=1`, `PING=1`, `VERSION=1`, `CONTAINERS=1`, `IMAGES=1`, `NETWORKS=1`, `VOLUMES=1`, `POST=1`, `EXEC=1`, and `BUILD=1` (required for Build Workspace).
- Blocks critical endpoints (`AUTH=0`, `SECRETS=0`, `SWARM=0`, `NODES=0`).

## Adding Local Templates

Arcane supports loading custom templates by scanning the `/app/data/templates` directory. This stack mounts the host's `./templates` directory, so you can manage your templates in the workspace:

```
compose/02-container-orchestration/arcane/templates/
└── wordpress/
    ├── compose.yaml
    └── .env.example
```

Templates placed here will automatically show up in Arcane's templates dialog.

## Resources

- [Official Website](https://getarcane.app/)
- [Arcane Installation Guide](https://getarcane.app/docs/get-started/installation)
- [Official Documentation](https://getarcane.app/docs)
- [GitHub Repository](https://github.com/getarcaneapp/arcane)
