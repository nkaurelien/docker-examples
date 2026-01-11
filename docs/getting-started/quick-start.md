# Quick Start

Guide rapide pour démarrer avec les exemples Docker.

## Prérequis

- Docker Engine 20.10+
- Docker Compose v2+
- Git

## Installation

```bash
# Clone le repository
git clone https://github.com/nkaurelien/docker-examples.git
cd docker-examples
```

## Démarrer un Service

### Exemple avec Traefik

```bash
cd api-managment/traefik

# Copier et éditer la configuration
cp .env.example .env

# Démarrer
docker compose up -d

# Vérifier
docker compose ps
docker compose logs -f
```

### Exemple avec Portainer

```bash
cd orchestration/portainer
docker compose up -d

# Accéder à https://localhost:9443
```

## Commandes Communes

```bash
# Démarrer
docker compose up -d

# Arrêter
docker compose down

# Logs
docker compose logs -f [service]

# Reconstruire
docker compose up -d --build

# Status
docker compose ps
```

## Configuration

Chaque projet contient :

- `compose.yml` - Configuration Docker Compose principale
- `.env.example` - Variables d'environnement à personnaliser
- `README.md` - Documentation spécifique

### Variables d'Environnement

```bash
# Copier le fichier exemple
cp .env.example .env

# Éditer selon vos besoins
nano .env
```

## Variantes

Certains projets proposent plusieurs variantes :

| Fichier | Description |
|---------|-------------|
| `compose.yml` | Configuration standard |
| `compose.socket-proxy.yml` | Avec docker-socket-proxy (sécurisé) |
| `compose.swarm.yml` | Pour Docker Swarm |
| `compose.ha.yml` | High Availability |

```bash
# Utiliser une variante
docker compose -f compose.socket-proxy.yml up -d
```

## Résolution DNS Locale

Pour les services avec domaines locaux (ex: `*.apps.local`), ajoutez les entrées DNS :

```bash
# Linux/macOS
sudo hostctl add domains apps apps.local traefik.apps.local portainer.apps.local

# Ou manuellement dans /etc/hosts
127.0.0.1 apps.local traefik.apps.local portainer.apps.local
```

## Prochaines Étapes

- [Docker Essentials](../docker/essentials.md) - Concepts de base
- [Docker Capabilities](../docker/capabilities.md) - Sécurité avancée
