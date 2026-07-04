# Arcane - Modern Self-Hosted Docker Dashboard

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

### 1. Preparation

Copy the example environment file:
```bash
cp .env.example .env
```

### 2. Generate Secrets

Arcane requires an encryption key and a JWT secret. Generate them using the following commands:

```bash
# Generate encryption key (32-byte hex)
openssl rand -hex 32

# Generate JWT secret
openssl rand -hex 32
```

Edit your `.env` file and insert the generated secrets:
```env
ENCRYPTION_KEY=your_generated_encryption_key
JWT_SECRET=your_generated_jwt_secret
```

### 3. Start the Stack

Launch the stack using Docker Compose:
```bash
docker compose up -d
```

Access the Arcane dashboard at:
- **Direct IP**: `http://localhost:3552`
- **Domain (via Traefik)**: `http://arcane.apps.local`

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ARCANE_PORT` | `3552` | Port on the host to access Arcane UI |
| `PROJECTS_DIR` | `./projects` | Directory on the host where project stacks are stored |
| `ENCRYPTION_KEY` | - | 32-byte hex key for database encryption (required) |
| `JWT_SECRET` | - | Secret key for JWT token signatures (required) |
| `PUID` | `1000` | User ID for container file permissions |
| `PGID` | `1000` | Group ID for container file permissions |
| `TZ` | `Europe/Paris` | Container timezone |
| `DOMAIN` | `apps.local` | Base domain for Traefik routing |

---

## Security Hardening (Docker Socket Proxy)

By default, Docker managers require mounting `/var/run/docker.sock` into the container, which gives the container full `root` access to the host system.

To secure this, this stack uses `tecnativa/docker-socket-proxy`. The proxy filters API calls and only allows the minimum necessary permissions for Arcane to operate:

- `CONTAINERS=1`, `IMAGES=1`, `NETWORKS=1`, `VOLUMES=1` (Read information)
- `EVENTS=1`, `PING=1`, `VERSION=1`, `INFO=1` (Get system events & status)
- `POST=1` (Allow container creation/deletion/updates)
- `EXEC=1` (Allow executing commands inside containers)
- **Disabled**: Swarm, Secrets, Configs, Plugins, Nodes, and build systems are completely blocked for security.

In addition, the socket proxy container runs:
- With `read_only: true` filesystem
- With `cap_drop: ALL` (no Linux capabilities)
- With `security_opt: - no-new-privileges:true`

---

## Adding Local Templates

Arcane allows you to load custom local templates that automatically appear in the template creation dialog. This stack mounts the local `./templates` directory directly to Arcane's templates repository path inside the container.

### Template Directory Structure

Add your Docker Compose files inside separate folders inside `./templates/`:

```
templates/
└── wordpress/
    ├── compose.yaml
    └── .env.example
```

- **compose.yaml** or **compose.yml**: The Docker Compose definition for the template.
- **.env.example** (optional): Template environment variables that the user will be prompted to fill in when deploying the template in Arcane.

A WordPress template example is included by default.

---

## Troubleshooting

### Check Container Status
```bash
docker compose ps
```

### View Application Logs
```bash
# View Arcane Manager logs
docker compose logs -f arcane

# View Docker Socket Proxy logs
docker compose logs -f docker-socket-proxy
```

### Reset Arcane Database (Warning: Data Loss)
```bash
docker compose down -v
# Delete stored projects if necessary
rm -rf ./projects
```

## References

- [Arcane Official Documentation](https://getarcane.app/docs)
- [Arcane GitHub Repository](https://github.com/getarcaneapp/arcane)
- [Docker Socket Proxy GitHub](https://github.com/Tecnativa/docker-socket-proxy)
