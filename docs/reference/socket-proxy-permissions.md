# Socket Proxy Permissions Reference

Liste complète des permissions docker-socket-proxy.

## Permissions GET (Lecture)

| Variable | Default | Description |
|----------|---------|-------------|
| `CONTAINERS` | `0` | Lire informations containers |
| `IMAGES` | `0` | Lister et inspecter images |
| `NETWORKS` | `0` | Lire informations réseaux |
| `VOLUMES` | `0` | Lister volumes |
| `SERVICES` | `0` | Lire services Swarm |
| `TASKS` | `0` | Lire tasks Swarm |
| `NODES` | `0` | Lire nodes Swarm |
| `INFO` | `0` | Docker system info |
| `EVENTS` | `0` | Stream événements Docker |
| `SECRETS` | `0` | Lire secrets |
| `CONFIGS` | `0` | Lire configs |
| `PLUGINS` | `0` | Lire plugins |
| `DISTRIBUTION` | `0` | Distribution info |
| `SWARM` | `0` | Swarm info |
| `SYSTEM` | `0` | System info complet |
| `SESSION` | `0` | Sessions |

## Permissions POST (Écriture)

| Variable | Default | Description |
|----------|---------|-------------|
| `POST` | `0` | Autoriser TOUTES les requêtes POST |
| `BUILD` | `0` | Build images |
| `COMMIT` | `0` | Commit containers |
| `EXEC` | `0` | Exécuter commandes dans containers |
| `ALLOW_START` | `0` | Démarrer containers |
| `ALLOW_STOP` | `0` | Arrêter containers |
| `ALLOW_RESTARTS` | `0` | Redémarrer containers |
| `GRPC` | `0` | gRPC (BuildKit) |

## Configurations par Service

### Traefik (Reverse Proxy)

```yaml
environment:
  - POST=0
  - CONTAINERS=1    # Labels discovery
  - NETWORKS=1      # Network routing
  - SERVICES=1      # Swarm services
  - TASKS=1         # Swarm tasks
  - EVENTS=1        # Auto-discovery
```

### Portainer (Full Management)

```yaml
environment:
  - POST=1
  - CONTAINERS=1
  - IMAGES=1
  - NETWORKS=1
  - VOLUMES=1
  - SERVICES=1
  - TASKS=1
  - NODES=1
  - INFO=1
  - EXEC=1
  - SYSTEM=1
  - EVENTS=1
  - ALLOW_START=1
  - ALLOW_STOP=1
  - ALLOW_RESTARTS=1
  - SECRETS=1
  - CONFIGS=1
```

### Glances (Monitoring)

```yaml
environment:
  - POST=0
  - CONTAINERS=1
  - INFO=1
  - EVENTS=1
```

### Ofelia (Cron Jobs)

```yaml
environment:
  - POST=1
  - CONTAINERS=1
  - EXEC=1
  - ALLOW_START=1
  - ALLOW_RESTARTS=1
```

### Watchtower (Auto-update)

```yaml
environment:
  - POST=1
  - CONTAINERS=1
  - IMAGES=1
  - ALLOW_START=1
  - ALLOW_STOP=1
  - ALLOW_RESTARTS=1
```

### Prometheus/cAdvisor (Metrics)

```yaml
environment:
  - POST=0
  - CONTAINERS=1
  - INFO=1
```

### Dozzle (Log Viewer)

```yaml
environment:
  - POST=0
  - CONTAINERS=1
  - EVENTS=1
```

## Template Complet

```yaml
services:
  socket-proxy:
    image: tecnativa/docker-socket-proxy:latest
    container_name: socket-proxy
    restart: unless-stopped
    networks:
      - socket-proxy
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      # Read permissions
      - CONTAINERS=1
      - IMAGES=0
      - NETWORKS=1
      - VOLUMES=0
      - SERVICES=1
      - TASKS=1
      - NODES=0
      - INFO=0
      - EVENTS=1
      - SECRETS=0
      - CONFIGS=0
      - PLUGINS=0
      - DISTRIBUTION=0
      - SWARM=0
      - SYSTEM=0
      - SESSION=0
      # Write permissions
      - POST=0
      - BUILD=0
      - COMMIT=0
      - EXEC=0
      - ALLOW_START=0
      - ALLOW_STOP=0
      - ALLOW_RESTARTS=0
      - GRPC=0

networks:
  socket-proxy:
    internal: true
```

## Sécurité

1. **Toujours `internal: true`** pour le réseau socket-proxy
2. **Monter en read-only** `:ro`
3. **`POST=0` par défaut** sauf si nécessaire
4. **Minimal permissions** - n'activer que le strict nécessaire
5. **Audit régulier** des permissions accordées

## Références

- [docker-socket-proxy GitHub](https://github.com/Tecnativa/docker-socket-proxy)
- [Docker API Reference](https://docs.docker.com/engine/api/)
