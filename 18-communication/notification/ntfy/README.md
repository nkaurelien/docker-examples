# ntfy - Simple Notification Service

A simple HTTP-based pub-sub notification service that allows you to send notifications to your phone or desktop via scripts from any computer.

## Features

- Simple HTTP API for sending notifications
- Web UI for subscribing to topics
- Mobile apps for iOS and Android
- No signup required (by default)
- Self-hosted and privacy-focused
- Supports attachments, priorities, and more

## Quick Start

### 1. Setup Environment

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env and customize your settings
nano .env
```

### 2. Start the Service

```bash
# Start ntfy
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f ntfy
```

### 3. Access ntfy

Open your browser and navigate to: `http://localhost:8900`

## Configuration

### Environment Variables

Edit `.env` file:

```env
# Project name
COMPOSE_PROJECT_NAME=ntfy-notification

# ntfy configuration
NTFY_BASE_URL=http://localhost:8900
NTFY_PORT=8900

# Authentication
NTFY_AUTH_DEFAULT_ACCESS=read-write  # Options: read-write, read-only, write-only, deny-all
NTFY_ENABLE_LOGIN=false

# Proxy
NTFY_BEHIND_PROXY=false

# User and Group IDs
UID=1000
GID=1000

# Timezone
TIMEZONE=UTC
```

### Authentication Options

- `read-write`: Anyone can read and write to all topics (default)
- `read-only`: Anyone can read, but writing requires authentication
- `write-only`: Anyone can write, but reading requires authentication
- `deny-all`: Both reading and writing require authentication

To enable authentication:
1. Set `NTFY_ENABLE_LOGIN=true`
2. Create users inside the container:
   ```bash
   docker exec -it ntfy ntfy user add <username>
   ```

## Usage Examples

### Send a Simple Notification

```bash
curl -d "Hello from ntfy!" http://localhost:8900/mytopic
```

### Send with Title

```bash
curl -H "Title: Backup Complete" -d "All databases backed up successfully" http://localhost:8900/backups
```

### Send with Priority

```bash
curl -H "Priority: high" -d "Disk space low!" http://localhost:8900/alerts
```

### Send with Tags (Emojis)

```bash
curl -H "Tags: warning,skull" -d "Critical error detected" http://localhost:8900/alerts
```

### Subscribe to Topics

Open `http://localhost:8900` in your browser and subscribe to topics like:
- `mytopic`
- `backups`
- `alerts`

Or use the mobile apps (iOS/Android) to receive notifications on your phone.

## Common Commands

```bash
# Start service
docker-compose up -d

# Stop service
docker-compose down

# View logs
docker-compose logs -f ntfy

# Restart service
docker-compose restart

# Open shell in container
docker-compose exec ntfy sh

# Create user (when authentication is enabled)
docker exec -it ntfy ntfy user add <username>

# List users
docker exec -it ntfy ntfy user list

# Remove user
docker exec -it ntfy ntfy user remove <username>
```

## Integration Examples

### Bash Script Notifications

```bash
#!/bin/bash
# Send notification when script completes
./my-long-running-script.sh
curl -d "Script completed!" http://localhost:8900/scripts
```

### Python Integration

```python
import requests

def send_notification(topic, message, title=None, priority=None):
    headers = {}
    if title:
        headers['Title'] = title
    if priority:
        headers['Priority'] = priority

    requests.post(f'http://localhost:8900/{topic}',
                  data=message,
                  headers=headers)

# Usage
send_notification('alerts', 'Database backup completed',
                  title='Backup Status', priority='high')
```

### Cron Job Notifications

```bash
# Add to crontab
0 2 * * * /path/to/backup.sh && curl -d "Backup completed" http://localhost:8900/backups || curl -d "Backup failed" http://localhost:8900/alerts
```

## Production Considerations

### Security

1. **Enable Authentication**: Set `NTFY_ENABLE_LOGIN=true` and create users
2. **Use HTTPS**: Put ntfy behind a reverse proxy (nginx, Caddy) with SSL
3. **Set Default Access**: Use `NTFY_AUTH_DEFAULT_ACCESS=deny-all` for private instances
4. **Firewall**: Restrict access to port 8900 if exposed

### Behind a Reverse Proxy

If using nginx or another reverse proxy:

```env
NTFY_BEHIND_PROXY=true
NTFY_BASE_URL=https://ntfy.yourdomain.com
```

Example nginx configuration:

```nginx
server {
    listen 443 ssl;
    server_name ntfy.yourdomain.com;

    location / {
        proxy_pass http://localhost:8900;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Persistence

Data is stored in Docker volumes:
- `cache/`: Message cache
- `data/`: User database and configuration

To backup:
```bash
docker-compose down
tar czf ntfy-backup-$(date +%Y%m%d).tar.gz cache/ data/
docker-compose up -d
```

## Troubleshooting

### Port Already in Use

If port 8900 is in use, change `NTFY_PORT` in `.env`:

```env
NTFY_PORT=8901
```

Then restart:
```bash
docker-compose down && docker-compose up -d
```

### Permission Errors

Check UID/GID settings in `.env`:

```bash
# Get your user ID and group ID
echo "UID=$(id -u) GID=$(id -g)"

# Update .env with these values
UID=1000
GID=1000
```

### Can't Receive Notifications

1. Check if service is running: `docker-compose ps`
2. Check logs: `docker-compose logs -f ntfy`
3. Verify base URL is correct in `.env`
4. Check firewall settings

## Resources

- Official Documentation: https://docs.ntfy.sh
- GitHub Repository: https://github.com/binwiederhier/ntfy
- Mobile Apps: Available on iOS App Store and Google Play Store
- Web Interface: Access at `http://localhost:8900`

## License

ntfy is open source and licensed under Apache License 2.0 / GPLv2.
