# Mailpit

Mailpit is a lightweight, fast email testing tool for developers. It captures all outgoing emails and provides a modern web interface to view them. It's a modern replacement for MailHog with better performance and more features.

## Quick Start

```bash
# Start with dev profile
docker compose --profile dev up -d

# Or without profile (remove 'profiles' from compose.yml)
docker compose up -d
```

## Access

- **Web UI**: http://localhost:8025
- **SMTP**: localhost:1025

## Features

- Modern, responsive web UI with dark mode
- Mobile/tablet email preview
- HTML email client compatibility testing
- Real-time updates via WebSockets
- Attachment support
- Search and filtering
- REST API for automation testing
- Persistent storage with SQLite

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `MAILPIT_UI_PORT` | `8025` | Web UI port |
| `MAILPIT_SMTP_PORT` | `1025` | SMTP port |
| `TZ` | `UTC` | Timezone |
| `MP_MAX_MESSAGES` | `5000` | Maximum messages to store |
| `MP_DATABASE` | `/data/mailpit.db` | Database file path |
| `MP_SMTP_AUTH_ACCEPT_ANY` | `1` | Accept any SMTP authentication |
| `MP_SMTP_AUTH_ALLOW_INSECURE` | `1` | Allow insecure SMTP auth |

## Application Configuration

Configure your application to send emails to Mailpit:

```env
SMTP_HOST=mailpit    # or localhost if not in Docker network
SMTP_PORT=1025
SMTP_TLS=false
SMTP_USERNAME=
SMTP_PASSWORD=
```

### Laravel

```env
MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
```

### Symfony

```env
MAILER_DSN=smtp://mailpit:1025
```

### Node.js (Nodemailer)

```javascript
const transporter = nodemailer.createTransport({
  host: 'mailpit',  // or 'localhost'
  port: 1025,
  secure: false
});
```

### Django

```python
EMAIL_HOST = 'mailpit'  # or 'localhost'
EMAIL_PORT = 1025
EMAIL_USE_TLS = False
```

### Spring Boot

```properties
spring.mail.host=mailpit
spring.mail.port=1025
```

## Docker Compose Integration

Add Mailpit to your existing project:

```yaml
services:
  # Your app services...

  mailpit:
    image: axllent/mailpit:latest
    profiles: [dev]
    ports:
      - "8025:8025"
      - "1025:1025"
    environment:
      - TZ=Europe/Paris
      - MP_SMTP_AUTH_ACCEPT_ANY=1
      - MP_SMTP_AUTH_ALLOW_INSECURE=1
```

Then start with:

```bash
docker compose --profile dev up -d
```

## API

Mailpit provides a REST API for automation:

```bash
# List messages
curl http://localhost:8025/api/v1/messages

# Get message by ID
curl http://localhost:8025/api/v1/message/{id}

# Delete all messages
curl -X DELETE http://localhost:8025/api/v1/messages
```

## Alternatives

- [Mailcatcher](../mailcatcher/) - Ruby-based mail catcher
- [MailHog](https://github.com/mailhog/MailHog) - Go-based (archived, Mailpit is the successor)
- [Inbucket](https://inbucket.org/) - Disposable email platform

## References

- [Mailpit GitHub](https://github.com/axllent/mailpit)
- [Jeff Geerling's Blog](https://www.jeffgeerling.com/blog/2026/mailpit-local-email-debugging/)
