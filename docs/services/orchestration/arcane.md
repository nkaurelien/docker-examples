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
cd 02-container-orchestration/arcane
cp .env.example .env
# Edit .env and set ENCRYPTION_KEY and JWT_SECRET
docker compose up -d
```

Access at: `http://localhost:3552` or `http://arcane.apps.local` (via Traefik)

## Adding Local Templates

Arcane supports loading custom templates by scanning the `/app/data/templates` directory. This stack mounts the host's `./templates` directory, so you can manage your templates in the workspace:

```
02-container-orchestration/arcane/templates/
└── wordpress/
    ├── compose.yaml
    └── .env.example
```

Templates placed here will automatically show up in Arcane's templates dialog.

## Resources

- [Official Website](https://getarcane.app/)
- [Documentation](https://getarcane.app/docs)
- [GitHub Repository](https://github.com/getarcaneapp/arcane)
