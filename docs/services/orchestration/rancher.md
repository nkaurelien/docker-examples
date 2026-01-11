# Rancher

Plateforme de gestion Kubernetes multi-cluster.

## Quick Start

```bash
cd orchestration/rancher
docker compose up -d
```

## Accès

- **URL** : https://localhost
- **Premier accès** : Récupérer le mot de passe bootstrap

```bash
docker logs rancher 2>&1 | grep "Bootstrap Password:"
```

## Ports

| Service | Port | Description |
|---------|------|-------------|
| Rancher UI | 443 | Interface HTTPS |
| Rancher HTTP | 80 | Redirection vers HTTPS |

## Configuration

### compose.yml basique

```yaml
services:
  rancher:
    image: rancher/rancher:latest
    privileged: true
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - rancher_data:/var/lib/rancher
```

## Liens

- [Documentation officielle](https://ranchermanager.docs.rancher.com/)
