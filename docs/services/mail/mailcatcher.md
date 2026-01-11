# Mailcatcher

Capture les emails en développement sans les envoyer réellement.

## Quick Start

```bash
cd mail-servers/mailcatcher
docker compose up -d
```

## Accès

- **Web UI** : http://localhost:1080
- **SMTP** : localhost:1025

## Ports

| Service | Port | Description |
|---------|------|-------------|
| Web UI | 1080 | Interface web |
| SMTP | 1025 | Serveur SMTP |

## Configuration

### compose.yml

```yaml
services:
  mailcatcher:
    image: schickling/mailcatcher
    ports:
      - "1080:1080"
      - "1025:1025"
```

### Configuration application

```bash
SMTP_HOST=mailcatcher
SMTP_PORT=1025
```

## Liens

- [Mailcatcher](https://mailcatcher.me/)
