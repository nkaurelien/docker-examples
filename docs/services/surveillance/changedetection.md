# ChangeDetection.io

Surveillance de changements sur des pages web.

## Quick Start

```bash
cd surveillance/changedetection
docker compose up -d
```

## Accès

- **Web UI** : http://localhost:5000

## Ports

| Service | Port | Description |
|---------|------|-------------|
| Web UI | 5000 | Interface web |

## Configuration

### compose.yml

```yaml
services:
  changedetection:
    image: ghcr.io/dgtlmoon/changedetection.io
    ports:
      - "5000:5000"
    volumes:
      - changedetection_data:/datastore
    environment:
      - PUID=1000
      - PGID=1000
```

## Fonctionnalités

- Notifications (email, Slack, Discord, etc.)
- Filtres CSS/XPath
- Comparaison visuelle
- API REST

## Liens

- [Documentation officielle](https://changedetection.io/)
- [GitHub](https://github.com/dgtlmoon/changedetection.io)
