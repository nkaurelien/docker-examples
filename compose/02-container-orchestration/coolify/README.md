# Coolify - Self-Hostable Heroku/Netlify/Vercel Alternative

Coolify is an open-source, self-hostable platform for deploying applications, databases, and services to your own servers. It's designed as an alternative to Vercel, Heroku, Netlify, and Railway.

## Features

- **Multi-Language Support**: Compatible with any language and framework
- **Docker Compatible**: Deploy any Docker-based service
- **280+ One-Click Services**: Pre-configured templates for popular services
- **Git Integration**: GitHub, GitLab, Bitbucket, and Gitea support
- **Automatic SSL**: Let's Encrypt certificates out of the box
- **Pull Request Deployments**: Separate environments for testing PRs
- **Multi-Server Deployment**: Deploy to any server with SSH access
- **Database Backups**: Automatic backups to S3-compatible storage
- **Real-time Monitoring**: Track deployments, servers, and resources
- **Team Collaboration**: Role-based permissions and project sharing
- **No Vendor Lock-in**: Full control over your data and infrastructure

## Supported Platforms

Deploy to any server with SSH access:
- VPS (DigitalOcean, Linode, Hetzner, Vultr)
- AWS EC2
- Google Cloud
- Azure
- Raspberry Pi
- On-premises servers

## Quick Start

### One-Line Installation (Recommended)

```bash
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

This script will:
1. Install Docker and Docker Compose
2. Set up Coolify with default configuration
3. Start all required services

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/coollabsio/coolify.git
cd coolify

# Copy environment file
cp .env.example .env

# Generate application key
./scripts/generate-key.sh

# Start Coolify
docker compose up -d
```

## Docker Compose Setup

```yaml
# compose.yml
version: "3.8"

services:
  coolify:
    image: ghcr.io/coollabsio/coolify:latest
    container_name: coolify
    restart: unless-stopped
    ports:
      - "8000:8000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - coolify-data:/data
      - coolify-ssh:/data/coolify/ssh
      - coolify-applications:/data/coolify/applications
      - coolify-databases:/data/coolify/databases
      - coolify-services:/data/coolify/services
    environment:
      - APP_ENV=production
      - APP_KEY=${APP_KEY}
      - DB_CONNECTION=pgsql
      - DB_HOST=coolify-db
      - DB_PORT=5432
      - DB_DATABASE=coolify
      - DB_USERNAME=coolify
      - DB_PASSWORD=${DB_PASSWORD}
      - REDIS_HOST=coolify-redis
    depends_on:
      - coolify-db
      - coolify-redis
    networks:
      - coolify-network
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.coolify.rule=Host(`coolify.apps.local`)"
      - "traefik.http.routers.coolify.entrypoints=websecure"
      - "traefik.http.routers.coolify.tls=true"
      - "traefik.http.services.coolify.loadbalancer.server.port=8000"

  coolify-db:
    image: postgres:15-alpine
    container_name: coolify-db
    restart: unless-stopped
    volumes:
      - coolify-postgres:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=coolify
      - POSTGRES_USER=coolify
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    networks:
      - coolify-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U coolify"]
      interval: 10s
      timeout: 5s
      retries: 5

  coolify-redis:
    image: redis:7-alpine
    container_name: coolify-redis
    restart: unless-stopped
    volumes:
      - coolify-redis-data:/data
    networks:
      - coolify-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  coolify-data:
  coolify-ssh:
  coolify-applications:
  coolify-databases:
  coolify-services:
  coolify-postgres:
  coolify-redis-data:

networks:
  coolify-network:
    driver: bridge
  traefik-public:
    external: true
```

## Configuration

### Environment Variables

Create a `.env` file:

```bash
# Application
APP_KEY=base64:your-generated-key-here
APP_ENV=production

# Database
DB_PASSWORD=your-secure-password

# Optional: SMTP for notifications
MAIL_HOST=smtp.example.com
MAIL_PORT=587
MAIL_USERNAME=your-email
MAIL_PASSWORD=your-password
MAIL_FROM_ADDRESS=coolify@example.com
```

### Generate APP_KEY

```bash
echo "base64:$(openssl rand -base64 32)"
```

## Usage

### Initial Setup

1. Access Coolify at `http://your-server:8000`
2. Create admin account
3. Add your server (localhost or remote)
4. Configure SSH keys for remote servers

### Deploy from Git

1. Go to Projects > New Project
2. Add new resource > Application
3. Select Git provider (GitHub, GitLab, etc.)
4. Choose repository and branch
5. Configure build settings
6. Deploy

### Deploy Docker Image

1. New Project > Add Resource
2. Select "Docker Image"
3. Enter image name and tag
4. Configure ports and environment
5. Deploy

### Deploy Database

1. New Project > Add Resource
2. Select "Database"
3. Choose type (PostgreSQL, MySQL, MongoDB, Redis, etc.)
4. Configure resources
5. Deploy

## One-Click Services

Coolify includes 280+ pre-configured services:

**Productivity**
- Nextcloud, OnlyOffice, Collabora
- Mattermost, Rocket.Chat
- Outline, BookStack

**Development**
- GitLab, Gitea, Forgejo
- Drone CI, Woodpecker CI
- SonarQube, Sentry

**Databases**
- PostgreSQL, MySQL, MariaDB
- MongoDB, Redis, ClickHouse
- Elasticsearch, Meilisearch

**Monitoring**
- Grafana, Prometheus
- Uptime Kuma, Healthchecks
- Plausible, Umami

**Storage**
- MinIO, Garage
- Nextcloud, Seafile

## Backup Configuration

### Database Backups to S3

1. Go to Settings > Backup
2. Configure S3-compatible storage:
   - Endpoint URL
   - Access Key
   - Secret Key
   - Bucket name
3. Enable automatic backups
4. Set backup schedule

### Manual Backup

```bash
# Backup Coolify data
docker exec coolify-db pg_dump -U coolify coolify > backup.sql

# Backup volumes
docker run --rm \
  -v coolify-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/coolify-backup.tar.gz -C /data .
```

## Multi-Server Setup

1. Go to Servers > Add Server
2. Enter server details:
   - Name
   - IP/Hostname
   - SSH Port
   - SSH User
3. Add SSH public key to remote server
4. Validate connection
5. Deploy applications to any server

## Monitoring & Notifications

### Notifications

Configure notifications for:
- Deployment success/failure
- Server issues
- Backup status

Supported channels:
- Discord
- Telegram
- Email
- Custom webhooks

### Metrics

Monitor in real-time:
- CPU usage
- Memory consumption
- Disk usage
- Network traffic

## Troubleshooting

```bash
# View Coolify logs
docker logs -f coolify

# Check all service status
docker compose ps

# Restart all services
docker compose restart

# Reset database (warning: data loss)
docker compose down -v
docker compose up -d

# Access container shell
docker exec -it coolify /bin/bash
```

## CLI Tool

```bash
# Install Coolify CLI
curl -fsSL https://cdn.coollabs.io/coolify/cli/install.sh | bash

# Login
coolify login

# List projects
coolify projects list

# Deploy application
coolify deploy --project-id <id>
```

## Documentation

- [Official Website](https://coolify.io/)
- [GitHub Repository](https://github.com/coollabsio/coolify)
- [Documentation](https://coolify.io/docs)
- [Discord Community](https://discord.gg/coolify)
