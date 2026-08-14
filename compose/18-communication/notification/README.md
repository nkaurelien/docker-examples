# Notification Services

This directory contains self-hosted notification solutions for different use cases.

## Available Services

### [ntfy](./ntfy/) - Simple Notification Service

A lightweight, HTTP-based pub-sub notification service for sending notifications to phones and desktops.

**Best for:**
- Simple script notifications
- Webhook endpoints
- Personal projects
- Quick notifications via HTTP/curl

**Features:**
- Simple HTTP API
- No signup required
- Web UI and mobile apps
- Self-hosted and privacy-focused

**Quick Start:**
```bash
cd ntfy
make setup
make up
```

Access at: http://localhost:8900

---

### [Novu](./novu/) - Enterprise Notification Platform

A comprehensive, multi-channel notification infrastructure platform with workflow engine and template management.

**Best for:**
- Production applications
- Multi-channel notifications (Email, SMS, Push, In-App)
- Complex notification workflows
- Team collaboration
- Transactional notifications

**Features:**
- Multi-channel support (Email, SMS, Push, Chat, In-App)
- Visual workflow builder
- Template management
- Provider integration (50+ providers)
- Subscriber management
- Analytics and logs
- Embeddable notification center

**Quick Start:**
```bash
cd novu
make setup
make generate-secrets  # Copy secrets to .env
make up
```

Access at:
- Dashboard: http://localhost:4000
- API: http://localhost:3000

---

## Comparison

| Feature | ntfy | Novu |
|---------|------|------|
| **Complexity** | Simple | Enterprise |
| **Setup Time** | 1 minute | 5 minutes |
| **Resource Usage** | Low (~50MB RAM) | High (~2GB RAM) |
| **Channels** | Push notifications only | Email, SMS, Push, Chat, In-App |
| **Workflow Engine** | No | Yes |
| **Template Management** | No | Yes |
| **API** | Simple HTTP | RESTful API |
| **UI Dashboard** | Basic web UI | Full management dashboard |
| **Database** | SQLite | MongoDB |
| **Use Case** | Personal, scripts | Production apps |

## Which One to Choose?

### Choose **ntfy** if you need:
- Simple notifications from scripts or cron jobs
- Minimal resource usage
- Quick setup (< 1 minute)
- Personal projects
- Webhook receiver

### Choose **Novu** if you need:
- Production-grade notification system
- Multiple notification channels
- Email templates and workflows
- Team collaboration
- Subscriber management
- Analytics and tracking
- Third-party provider integration

## Examples

### ntfy - Send Notification
```bash
# Simple notification
curl -d "Backup completed!" http://localhost:8900/backups

# With title and priority
curl -H "Title: Database Backup" \
     -H "Priority: high" \
     -d "All databases backed up successfully" \
     http://localhost:8900/backups
```

### Novu - Send Notification
```javascript
import { Novu } from '@novu/node';

const novu = new Novu('YOUR_API_KEY');

await novu.trigger('welcome-email', {
  to: {
    subscriberId: 'user-123',
    email: 'user@example.com',
  },
  payload: {
    userName: 'John Doe',
  },
});
```

## Resources

- [ntfy Documentation](./ntfy/README.md)
- [Novu Documentation](./novu/README.md)
- [ntfy Official Docs](https://docs.ntfy.sh)
- [Novu Official Docs](https://docs.novu.co)
