# Docker Socket Proxy

Le Docker Socket Proxy (tecnativa/docker-socket-proxy) permet un accès sécurisé et granulaire à l'API Docker.

## Pourquoi l'utiliser ?

Exposer directement `/var/run/docker.sock` à un container donne un accès root complet à l'hôte. Le socket-proxy permet de :

- Limiter les opérations autorisées (GET only, pas de POST)
- Restreindre les endpoints accessibles
- Isoler le socket dans un réseau interne

## Configuration de Base

```yaml
services:
  socket-proxy:
    image: tecnativa/docker-socket-proxy:latest
    restart: unless-stopped
    networks:
      - socket-proxy
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - CONTAINERS=1
      - NETWORKS=1
      - SERVICES=1
      - TASKS=1
      - EVENTS=1

networks:
  socket-proxy:
    internal: true
```

## Permissions Disponibles

### Lecture (GET)

| Variable | Description |
|----------|-------------|
| `CONTAINERS` | Lire infos containers |
| `IMAGES` | Lister images |
| `NETWORKS` | Lire infos réseaux |
| `VOLUMES` | Lister volumes |
| `SERVICES` | Lire services Swarm |
| `TASKS` | Lire tasks Swarm |
| `INFO` | Docker system info |
| `EVENTS` | Stream d'événements |
| `NODES` | Lire nodes Swarm |
| `SECRETS` | Lire secrets |
| `CONFIGS` | Lire configs |

### Écriture (POST)

| Variable | Description |
|----------|-------------|
| `POST` | Autoriser toutes les requêtes POST |
| `ALLOW_START` | Démarrer containers |
| `ALLOW_STOP` | Arrêter containers |
| `ALLOW_RESTARTS` | Redémarrer containers |
| `BUILD` | Build images |
| `COMMIT` | Commit containers |
| `EXEC` | Exécuter commandes |

## Exemples par Cas d'Usage

### Traefik (Read-only)

```yaml
environment:
  - POST=0
  - CONTAINERS=1
  - NETWORKS=1
  - SERVICES=1
  - TASKS=1
  - EVENTS=1
```

### Portainer (Full management)

```yaml
environment:
  - POST=1
  - CONTAINERS=1
  - IMAGES=1
  - NETWORKS=1
  - VOLUMES=1
  - SERVICES=1
  - TASKS=1
  - INFO=1
  - EXEC=1
  - SYSTEM=1
  - EVENTS=1
  - ALLOW_START=1
  - ALLOW_STOP=1
  - ALLOW_RESTARTS=1
```

### Ofelia (Cron jobs)

```yaml
environment:
  - POST=1
  - CONTAINERS=1
  - EXEC=1
  - ALLOW_START=1
  - ALLOW_RESTARTS=1
```

### Glances (Monitoring)

```yaml
environment:
  - POST=0
  - CONTAINERS=1
  - INFO=1
  - EVENTS=1
```

## Utilisation

### Connecter un service au proxy

```yaml
services:
  socket-proxy:
    image: tecnativa/docker-socket-proxy:latest
    networks:
      - socket-proxy
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - CONTAINERS=1

  traefik:
    image: traefik:v3.6
    depends_on:
      - socket-proxy
    networks:
      - socket-proxy
      - web
    command:
      - "--providers.docker.endpoint=tcp://socket-proxy:2375"

networks:
  socket-proxy:
    internal: true
  web:
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        Host                              │
│  ┌─────────────────────────────────────────────────┐    │
│  │              Docker Daemon                       │    │
│  │         /var/run/docker.sock                    │    │
│  └─────────────────────────────────────────────────┘    │
│                          │                               │
│                          │ :ro                           │
│                          ▼                               │
│  ┌─────────────────────────────────────────────────┐    │
│  │           Socket Proxy Container                 │    │
│  │      (tecnativa/docker-socket-proxy)            │    │
│  │         - Filtre les requêtes                   │    │
│  │         - Expose port 2375                      │    │
│  └─────────────────────────────────────────────────┘    │
│                          │                               │
│               Internal Network                           │
│                          │                               │
│  ┌──────────────────┐   │   ┌──────────────────┐       │
│  │     Traefik      │◄──┴──►│    Portainer     │       │
│  │ tcp://socket-    │       │ tcp://socket-    │       │
│  │   proxy:2375     │       │   proxy:2375     │       │
│  └──────────────────┘       └──────────────────┘       │
└─────────────────────────────────────────────────────────┘
```

## Sécurité

1. **Réseau interne** - Toujours utiliser `internal: true`
2. **Read-only mount** - Monter le socket en `:ro`
3. **Minimal permissions** - N'activer que le nécessaire
4. **POST=0 par défaut** - Désactiver les écritures si possible

## Références

- [docker-socket-proxy GitHub](https://github.com/Tecnativa/docker-socket-proxy)
- [Traefik with Socket Proxy](https://doc.traefik.io/traefik/providers/docker/#docker-api-access)
