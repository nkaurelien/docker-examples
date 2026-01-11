# Erugo

Plateforme de partage de fichiers self-hosted avec interface Vue.js.

## Quick Start

```bash
cd file-sharing/erugo
docker compose up -d
```

## Accès

- **URL** : http://localhost:9998

## Ports

| Service | Port | Description |
|---------|------|-------------|
| Web UI | 9998 | Interface web |

## Configuration

### Variables d'environnement

```bash
# Port d'exposition
ERUGO_PORT=9998

# URL de l'application
APP_URL=http://localhost:9998

# Environnement
APP_ENV=production
```

### Volumes

| Volume | Description |
|--------|-------------|
| `erugo_storage` | Fichiers uploadés et données |

## Fonctionnalités

- Partage de fichiers sécurisé
- Interface utilisateur élégante (Vue.js)
- Backend PHP/Laravel robuste
- Self-hosted (données sur votre infrastructure)
- Open source (MIT license)

## Pourquoi self-host ?

- **Vos données, vos règles** : Pas d'accès tiers, pas de data mining
- **Déployez partout** : Serveur, VPS, Raspberry Pi
- **Open source** : Code inspectable, contributions bienvenues

## Liens

- [GitHub](https://github.com/wardy784/erugo)
- [Docker Hub](https://hub.docker.com/r/wardy784/erugo)
