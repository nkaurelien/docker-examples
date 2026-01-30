# Socket Proxy Permissions Reference

Guide complet des permissions docker-socket-proxy pour sécuriser l'accès à l'API Docker.

## Pourquoi utiliser Socket Proxy ?

Le socket Docker (`/var/run/docker.sock`) donne un accès **root** complet au système hôte. Le monter directement dans un conteneur est un risque de sécurité majeur.

**Docker Socket Proxy** filtre les requêtes API et n'autorise que les opérations explicitement permises.

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
| `VERSION` | `0` | Version Docker |
| `PING` | `0` | Ping API |
| `AUTH` | `0` | Authentification registry |

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
  - CONTAINERS=1    # Labels discovery
  - NETWORKS=1      # Network routing
  - SERVICES=1      # Swarm services
  - TASKS=1         # Swarm tasks
  - EVENTS=1        # Auto-discovery
  - INFO=1          # System info
  - VERSION=1       # Version check
  - PING=1          # Health check
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
  - BUILD=1
  - COMMIT=1
  - ALLOW_START=1
  - ALLOW_STOP=1
  - ALLOW_RESTARTS=1
  - SECRETS=1
  - CONFIGS=1
  - VERSION=1
  - PING=1
```

### Coolify / Dokploy (PaaS)

```yaml
environment:
  - CONTAINERS=1
  - IMAGES=1
  - NETWORKS=1
  - VOLUMES=1
  - EXEC=1
  - TASKS=1
  - BUILD=1
  - COMMIT=1
  - EVENTS=1
  - INFO=1
  - PING=1
  - POST=1
  - VERSION=1
  # Disabled
  - AUTH=0
  - SECRETS=0
  - SWARM=0
  - CONFIGS=0
  - NODES=0
  - PLUGINS=0
  - SERVICES=0
  - SYSTEM=0
```

### Gitea Actions Runner (CI/CD)

```yaml
environment:
  - CONTAINERS=1
  - IMAGES=1
  - NETWORKS=1
  - VOLUMES=1
  - EXEC=1
  - TASKS=1
  - BUILD=1
  - EVENTS=1
  - INFO=1
  - PING=1
  - POST=1
  - VERSION=1
  # Disabled
  - AUTH=0
  - SECRETS=0
  - SWARM=0
```

### Glances (Monitoring)

```yaml
environment:
  - CONTAINERS=1
  - INFO=1
  - EVENTS=1
  - VERSION=1
  - PING=1
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
  - CONTAINERS=1
  - INFO=1
  - VERSION=1
```

### Dozzle (Log Viewer)

```yaml
environment:
  - CONTAINERS=1
  - EVENTS=1
```

### NeuVector (Container Security)

```yaml
environment:
  - CONTAINERS=1
  - IMAGES=1
  - NETWORKS=1
  - VOLUMES=1
  - INFO=1
  - EVENTS=1
  - VERSION=1
  - PING=1
```

## Template Complet

```yaml
services:
  socket-proxy:
    image: tecnativa/docker-socket-proxy:latest
    container_name: socket-proxy
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      # Logging
      - LOG_LEVEL=info
      # Read permissions
      - CONTAINERS=1
      - IMAGES=0
      - NETWORKS=1
      - VOLUMES=0
      - SERVICES=1
      - TASKS=1
      - NODES=0
      - INFO=1
      - EVENTS=1
      - SECRETS=0
      - CONFIGS=0
      - PLUGINS=0
      - DISTRIBUTION=0
      - SWARM=0
      - SYSTEM=0
      - SESSION=0
      - VERSION=1
      - PING=1
      - AUTH=0
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
      - socket-proxy
    # Security hardening
    read_only: true
    tmpfs:
      - /run
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:2375/version"]
      interval: 30s
      timeout: 5s
      retries: 3

networks:
  socket-proxy:
    driver: bridge
    internal: true
```

## Connexion depuis un conteneur

```yaml
services:
  my-app:
    image: my-app:latest
    environment:
      - DOCKER_HOST=tcp://socket-proxy:2375
    depends_on:
      socket-proxy:
        condition: service_healthy
    networks:
      - socket-proxy
```

## Sécurité

### Bonnes pratiques

1. **Réseau interne** : Toujours `internal: true` pour le réseau socket-proxy
2. **Lecture seule** : Monter le socket en `:ro`
3. **POST désactivé** : `POST=0` par défaut, activer uniquement si nécessaire
4. **Permissions minimales** : N'activer que le strict nécessaire
5. **Conteneur read-only** : `read_only: true` sur le proxy
6. **Capabilities** : `cap_drop: ALL` et `no-new-privileges: true`
7. **Health check** : Vérifier que le proxy répond

### Audit des permissions

```bash
# Lister les conteneurs avec accès au socket
docker ps --filter "volume=/var/run/docker.sock" --format "{{.Names}}"

# Vérifier les permissions d'un socket-proxy
docker exec socket-proxy env | grep -E "^(CONTAINERS|IMAGES|POST|EXEC)="
```

### Risques à éviter

| Permission | Risque si activé |
|------------|------------------|
| `POST=1` | Création/suppression de conteneurs |
| `EXEC=1` | Exécution de commandes arbitraires |
| `VOLUMES=1` + `POST=1` | Montage de volumes sensibles |
| `AUTH=1` | Accès aux credentials registry |
| `SECRETS=1` | Lecture des secrets Swarm |

## Projets utilisant Socket Proxy

| Projet | Répertoire | Permissions |
|--------|------------|-------------|
| Traefik | `01-infrastructure/traefik/` | Lecture seule |
| Portainer | `02-container-orchestration/portainer/` | Full management |
| Coolify | `02-container-orchestration/coolify/` | PaaS |
| Dokploy | `02-container-orchestration/dokploy/` | PaaS |
| Gitea Runner | `08-code-management/gitea/` | CI/CD |
| Glances | `05-monitoring-reporting/observability/monitoring/glances/` | Monitoring |

## Références

- [docker-socket-proxy GitHub](https://github.com/Tecnativa/docker-socket-proxy)
- [Docker API Reference](https://docs.docker.com/engine/api/)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
