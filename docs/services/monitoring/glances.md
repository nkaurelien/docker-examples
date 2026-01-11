# Glances

Outil de monitoring système cross-platform en temps réel.

## Quick Start

```bash
cd monitoring/glances
docker compose up -d
```

## Accès

- **Web UI** : http://localhost:61208

## Ports

| Service | Port | Description |
|---------|------|-------------|
| Glances Web | 61208 | Interface web |

## Configuration

### compose.yml

```yaml
services:
  glances:
    image: nicolargo/glances:latest
    environment:
      - GLANCES_OPT=-w
    ports:
      - "61208:61208"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    pid: host
```

## Fonctionnalités

- CPU, mémoire, disque, réseau
- Processus et conteneurs Docker
- Alertes configurables
- Export vers InfluxDB, Prometheus

## Liens

- [Documentation officielle](https://glances.readthedocs.io/)
- [GitHub](https://github.com/nicolargo/glances)
