# Mailpit

Mailpit is a lightweight email testing tool for developers. It captures all outgoing emails and provides a web interface to view them.

## Quick Start

```bash
docker compose up -d
```

## Access

- **Web UI**: http://localhost:8025
- **SMTP**: localhost:1025

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `MP_MAX_MESSAGES` | `5000` | Maximum number of messages to store |
| `MP_DATABASE` | `/data/mailpit.db` | Database file path |
| `MP_SMTP_AUTH_ACCEPT_ANY` | `1` | Accept any SMTP authentication |
| `MP_SMTP_AUTH_ALLOW_INSECURE` | `1` | Allow insecure SMTP authentication |

## Usage in Applications

Configure your application to use Mailpit as SMTP server:

```env
SMTP_HOST=localhost
SMTP_PORT=1025
SMTP_USERNAME=any
SMTP_PASSWORD=any
```

### Laravel

```env
MAIL_MAILER=smtp
MAIL_HOST=localhost
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
```

### Node.js (Nodemailer)

```javascript
const transporter = nodemailer.createTransport({
  host: 'localhost',
  port: 1025,
  secure: false
});
```

## Features

- Web UI for viewing emails
- Real-time updates via WebSockets
- HTML and plain text preview
- Attachment support
- Search and filtering
- REST API for automation
- SMTP with optional authentication

## Alternatives

- [Mailcatcher](../mailcatcher/) - Ruby-based mail catcher
- [MailHog](https://github.com/mailhog/MailHog) - Go-based (archived)
- [Inbucket](https://inbucket.org/) - Disposable email platform
