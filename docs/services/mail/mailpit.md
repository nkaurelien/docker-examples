# Mailpit

Mailpit est un outil de test email léger et rapide pour les développeurs. Il capture tous les emails sortants et fournit une interface web moderne.

## Quick Start

```bash
cd mail-servers/mailpit

# Avec profil dev
docker compose --profile dev up -d

# Sans profil
docker compose up -d
```

## Accès

- **Web UI**: http://localhost:8025
- **SMTP**: localhost:1025

## Features

- Interface web moderne avec dark mode
- Prévisualisation mobile/tablet
- Test de compatibilité HTML email
- Mises à jour temps réel (WebSockets)
- Support pièces jointes
- Recherche et filtrage
- API REST pour automation
- Stockage persistant SQLite

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `MAILPIT_UI_PORT` | `8025` | Port Web UI |
| `MAILPIT_SMTP_PORT` | `1025` | Port SMTP |
| `TZ` | `UTC` | Timezone |
| `MP_MAX_MESSAGES` | `5000` | Messages max stockés |

## Configuration Applications

### Variables génériques

```env
SMTP_HOST=mailpit
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
  host: 'mailpit',
  port: 1025,
  secure: false
});
```

### Django

```python
EMAIL_HOST = 'mailpit'
EMAIL_PORT = 1025
EMAIL_USE_TLS = False
```

### Spring Boot

```properties
spring.mail.host=mailpit
spring.mail.port=1025
```

## Intégration Docker Compose

Ajouter Mailpit à un projet existant :

```yaml
services:
  # Vos services...

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

Démarrer avec :

```bash
docker compose --profile dev up -d
```

## API REST

```bash
# Lister les messages
curl http://localhost:8025/api/v1/messages

# Obtenir un message
curl http://localhost:8025/api/v1/message/{id}

# Supprimer tous les messages
curl -X DELETE http://localhost:8025/api/v1/messages
```

## Alternatives

- [Mailcatcher](mailcatcher.md) - Ruby-based
- [MailHog](https://github.com/mailhog/MailHog) - Go-based (archivé)
- [Inbucket](https://inbucket.org/) - Plateforme email jetable

## Références

- [Mailpit GitHub](https://github.com/axllent/mailpit)
- [Jeff Geerling's Blog](https://www.jeffgeerling.com/blog/2026/mailpit-local-email-debugging/)
