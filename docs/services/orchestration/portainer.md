# Portainer

Interface web pour gérer Docker et Kubernetes.

## Quick Start

```bash
cd orchestration/portainer
docker compose up -d
```

## Accès

- **URL** : https://localhost:9443
- **Premier accès** : Créer un compte admin

## Ports

| Service | Port | Description |
|---------|------|-------------|
| Portainer UI | 9443 | Interface HTTPS |
| Portainer Agent | 8000 | Communication agents |

## Configuration

### compose.yml basique

```yaml
services:
  portainer:
    image: portainer/portainer-ce:latest
    ports:
      - "9443:9443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
```

## Liens

- [Documentation officielle](https://docs.portainer.io/)
