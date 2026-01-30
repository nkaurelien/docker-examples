# Uptime Kuma - Self-Hosted Uptime Monitoring

Uptime Kuma is a fancy self-hosted monitoring tool. It's a lightweight, open-source alternative to services like Pingdom, StatusCake, and UptimeRobot.

## Features

- **Multiple Monitor Types**: HTTP(S), TCP, Ping, DNS, Docker, Steam, MQTT, and more
- **Status Pages**: Beautiful public status pages
- **Notifications**: 90+ notification services (Slack, Discord, Telegram, Email, etc.)
- **Multi-Language**: 30+ languages supported
- **2FA**: Two-factor authentication
- **Proxy Support**: Monitor behind proxies
- **Certificate Monitoring**: SSL/TLS expiry alerts
- **Response Time Charts**: Historical performance data
- **Tags & Groups**: Organize monitors efficiently
- **API**: REST API for automation
- **Dark Mode**: Easy on the eyes

## Quick Start

```bash
cd 05-monitoring-reporting/uptime-kuma
docker compose up -d
```

Access Uptime Kuma at: http://localhost:3001

On first visit, create your admin account.

## Monitor Types

| Type | Description |
|------|-------------|
| **HTTP(S)** | Check website availability and response |
| **TCP Port** | Check if a port is open |
| **Ping** | ICMP ping check |
| **DNS** | DNS record monitoring |
| **Docker Container** | Monitor container status |
| **Steam Game Server** | Game server monitoring |
| **MQTT** | MQTT broker check |
| **Keyword** | Check for specific content |
| **JSON Query** | Parse JSON responses |
| **gRPC** | gRPC health checks |
| **Gamedig** | Game server protocol |
| **Radius** | RADIUS server check |
| **MongoDB** | Database connection |
| **MySQL/MariaDB** | Database connection |
| **PostgreSQL** | Database connection |
| **Redis** | Cache connection |

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TZ` | `UTC` | Timezone |
| `UMASK` | `0022` | File permissions |
| `UPTIME_KUMA_PORT` | `3001` | Listen port |
| `DATA_DIR` | `/app/data` | Data directory |

### Docker Socket Monitoring

To monitor Docker containers:

```yaml
services:
  uptime-kuma:
    image: louislam/uptime-kuma:latest
    volumes:
      - uptime-kuma-data:/app/data
      - /var/run/docker.sock:/var/run/docker.sock:ro
```

## Status Pages

Create public status pages for your services:

1. Go to **Status Pages** in the menu
2. Click **New Status Page**
3. Add monitors to the page
4. Customize appearance (logo, colors, description)
5. Share the public URL

### Custom Domain

Configure Traefik for a custom status page domain:

```yaml
labels:
  - "traefik.http.routers.status-page.rule=Host(`status.example.com`)"
```

## Notifications

### Supported Services (90+)

- **Chat**: Slack, Discord, Telegram, Microsoft Teams, Mattermost
- **Email**: SMTP, SendGrid, Mailgun
- **Push**: Pushover, Pushbullet, Gotify, ntfy
- **Incident Management**: PagerDuty, Opsgenie, VictorOps
- **Webhooks**: Custom HTTP webhooks
- **Mobile**: Apprise, Bark
- **And many more...**

### Slack Setup

1. Create Slack Incoming Webhook
2. In Uptime Kuma: Settings > Notifications > Setup Notification
3. Select "Slack" and paste webhook URL
4. Test and save

### Discord Setup

1. Create Discord Webhook in channel settings
2. In Uptime Kuma: Settings > Notifications > Setup Notification
3. Select "Discord" and paste webhook URL
4. Customize message format

### Email (SMTP)

```
SMTP Host: smtp.example.com
SMTP Port: 587
Security: STARTTLS
Username: your-email@example.com
Password: your-password
From Email: alerts@example.com
To Email: admin@example.com
```

## API Usage

Enable API in Settings > API Keys.

### List Monitors

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  http://localhost:3001/api/monitors
```

### Get Monitor Status

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  http://localhost:3001/api/monitors/1
```

### Pause/Resume Monitor

```bash
# Pause
curl -X POST -H "Authorization: Bearer YOUR_API_KEY" \
  http://localhost:3001/api/monitors/1/pause

# Resume
curl -X POST -H "Authorization: Bearer YOUR_API_KEY" \
  http://localhost:3001/api/monitors/1/resume
```

## Maintenance Windows

Schedule maintenance to prevent false alerts:

1. Go to **Maintenance** in the menu
2. Click **New Maintenance**
3. Select affected monitors
4. Set schedule (one-time or recurring)
5. Add description

## Backup & Restore

### Backup

```bash
# Stop container first for consistent backup
docker compose stop

# Backup data volume
docker run --rm \
  -v uptime-kuma-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/uptime-kuma-backup.tar.gz -C /data .

# Restart
docker compose start
```

### Restore

```bash
# Stop container
docker compose stop

# Restore data
docker run --rm \
  -v uptime-kuma-data:/data \
  -v $(pwd):/backup \
  alpine sh -c "rm -rf /data/* && tar xzf /backup/uptime-kuma-backup.tar.gz -C /data"

# Start
docker compose start
```

### Export/Import (Built-in)

1. Settings > Backup
2. Export: Download JSON backup file
3. Import: Upload JSON backup file

## High Availability

For critical monitoring, run multiple instances:

```yaml
services:
  uptime-kuma-1:
    image: louislam/uptime-kuma:latest
    volumes:
      - uptime-kuma-data-1:/app/data

  uptime-kuma-2:
    image: louislam/uptime-kuma:latest
    volumes:
      - uptime-kuma-data-2:/app/data
```

Note: Instances don't sync - configure monitors on each.

## Troubleshooting

### View Logs

```bash
docker logs -f uptime-kuma
```

### Reset Password

```bash
# Access container
docker exec -it uptime-kuma /bin/sh

# Reset via CLI
npm run reset-password
```

### Database Issues

```bash
# Backup and recreate database
docker exec uptime-kuma cp /app/data/kuma.db /app/data/kuma.db.backup

# Check database integrity
docker exec uptime-kuma sqlite3 /app/data/kuma.db "PRAGMA integrity_check"
```

### Common Issues

**Cannot connect to monitored service**
- Check network connectivity from container
- Verify firewall rules
- Try TCP monitor instead of HTTP

**High CPU usage**
- Reduce monitoring frequency
- Decrease number of monitors
- Check for network timeouts

**Notifications not sending**
- Verify notification service credentials
- Check container can reach external services
- Test notification manually

## Security

1. **Strong Password**: Use complex admin password
2. **2FA**: Enable two-factor authentication
3. **Reverse Proxy**: Use HTTPS via Traefik
4. **API Keys**: Rotate API keys regularly
5. **Updates**: Keep image updated

## Documentation

- [Official Website](https://uptime.kuma.pet/)
- [GitHub Repository](https://github.com/louislam/uptime-kuma)
- [Wiki](https://github.com/louislam/uptime-kuma/wiki)
- [Docker Hub](https://hub.docker.com/r/louislam/uptime-kuma)
