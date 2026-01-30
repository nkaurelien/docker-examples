# Dokploy - Self-Hosted PaaS (Vercel/Heroku Alternative)

Dokploy is a stable, easy-to-use deployment solution designed to simplify application management. It's a free, self-hostable alternative to platforms like Heroku, Vercel, and Netlify.

## Features

- **Flexible Deployment**: Deploy using Nixpacks, Heroku Buildpacks, or custom Dockerfiles
- **Docker Compose Support**: Native support for complex multi-container applications
- **Multi-Server Deployment**: Scale across multiple servers with minimal configuration
- **Docker Swarm Integration**: Built-in cluster support for high availability
- **Database Management**: MySQL, PostgreSQL, MongoDB, MariaDB, and Redis
- **Traefik Integration**: Automatic domain and SSL certificate management
- **Real-time Monitoring**: CPU, memory, storage, and network metrics
- **Backup System**: Built-in backup functionality for databases
- **User Management**: Advanced roles and permissions
- **Template Library**: 50+ pre-built templates (Supabase, Cal.com, PocketBase, etc.)
- **API & CLI**: Complete programmatic access

## Quick Start

### One-Line Installation (Recommended)

```bash
curl -sSL https://dokploy.com/install.sh | sh
```

This script will:
1. Install Docker if not present
2. Set up Dokploy with default configuration
3. Start the Dokploy service

### Docker Installation

```bash
docker run -d \
  --name dokploy \
  --restart unless-stopped \
  -p 3000:3000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v dokploy-data:/app/data \
  dokploy/dokploy:latest
```

## Docker Compose Setup

```yaml
# compose.yml
version: "3.8"

services:
  dokploy:
    image: dokploy/dokploy:latest
    container_name: dokploy
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - dokploy-data:/app/data
    environment:
      - NODE_ENV=production
    networks:
      - dokploy-network
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.dokploy.rule=Host(`dokploy.apps.local`)"
      - "traefik.http.routers.dokploy.entrypoints=websecure"
      - "traefik.http.routers.dokploy.tls=true"
      - "traefik.http.services.dokploy.loadbalancer.server.port=3000"

volumes:
  dokploy-data:

networks:
  dokploy-network:
    driver: bridge
  traefik-public:
    external: true
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_ENV` | `production` | Node.js environment |
| `DATABASE_URL` | - | PostgreSQL connection string (optional) |
| `REDIS_URL` | - | Redis connection string (optional) |

### Traefik Integration

Dokploy has built-in Traefik integration for:
- Automatic SSL certificates via Let's Encrypt
- Domain routing
- Load balancing

### Multi-Server Setup

1. Install Dokploy on the main server
2. Add remote servers via the UI (Settings > Servers)
3. Deploy applications to any connected server

## Usage

### Deploy from Git

1. Go to Projects > Create Project
2. Select "From Git Repository"
3. Enter repository URL and branch
4. Configure build settings (Nixpacks/Dockerfile)
5. Deploy

### Deploy with Docker Compose

1. Create a new project
2. Select "Docker Compose"
3. Upload or paste your compose.yml
4. Configure environment variables
5. Deploy

### Deploy Database

1. Go to Databases > Create Database
2. Select database type (PostgreSQL, MySQL, etc.)
3. Configure resources and backup schedule
4. Deploy

## Templates

Dokploy includes 50+ one-click deployment templates:

- **CMS**: WordPress, Ghost, Strapi, Directus
- **Databases**: PostgreSQL, MySQL, MongoDB, Redis
- **Analytics**: Plausible, Umami, PostHog
- **Storage**: MinIO, Nextcloud
- **Dev Tools**: Gitea, n8n, Appwrite
- **Communication**: Mattermost, Rocket.Chat

## Monitoring

Access real-time metrics:
- CPU usage per container
- Memory consumption
- Network I/O
- Storage usage
- Application logs

## Backup & Restore

### Database Backups

```bash
# Manual backup via UI: Databases > Select DB > Backups > Create Backup

# Automatic backups: Configure schedule in database settings
```

### Full System Backup

```bash
# Backup Dokploy data
docker run --rm \
  -v dokploy-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/dokploy-backup.tar.gz -C /data .
```

## Troubleshooting

```bash
# View Dokploy logs
docker logs -f dokploy

# Check container status
docker ps -a | grep dokploy

# Restart Dokploy
docker restart dokploy

# Access container shell
docker exec -it dokploy /bin/sh
```

## Documentation

- [Official Website](https://dokploy.com/)
- [GitHub Repository](https://github.com/Dokploy/dokploy)
- [Documentation](https://docs.dokploy.com/)
- [Discord Community](https://discord.gg/dokploy)
