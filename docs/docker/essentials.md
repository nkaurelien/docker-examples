# Docker Essentials

Guide des concepts essentiels de Docker et Docker Compose.

## Structure Docker Compose

```yaml
services:
  app:
    image: nginx:latest
    container_name: my-app
    restart: unless-stopped
    ports:
      - "80:80"
    volumes:
      - ./data:/app/data
    environment:
      - TZ=Europe/Paris
    networks:
      - frontend

networks:
  frontend:
    driver: bridge

volumes:
  app-data:
```

## Restart Policies

| Policy | Description |
|--------|-------------|
| `no` | Ne redémarre jamais (défaut) |
| `always` | Redémarre toujours |
| `unless-stopped` | Redémarre sauf si arrêté manuellement |
| `on-failure` | Redémarre uniquement en cas d'erreur |

```yaml
services:
  app:
    restart: unless-stopped
```

## Ports

```yaml
ports:
  - "8080:80"           # host:container
  - "443:443"           # HTTPS
  - "3000"              # Random host port
  - "127.0.0.1:8080:80" # Localhost only
  - "8080:80/udp"       # UDP
```

## Volumes

### Types de volumes

```yaml
volumes:
  # Named volume (géré par Docker)
  - app-data:/app/data

  # Bind mount (chemin local)
  - ./config:/app/config

  # Read-only
  - ./config:/app/config:ro

  # Tmpfs (RAM)
  - type: tmpfs
    target: /tmp
```

### Déclaration des volumes

```yaml
volumes:
  app-data:
    name: my-app-data
    driver: local
```

## Environment Variables

```yaml
environment:
  # Format liste
  - DATABASE_URL=postgres://localhost/db
  - DEBUG=true

  # Format map
  DATABASE_URL: postgres://localhost/db
  DEBUG: "true"
```

### Avec fichier .env

```yaml
env_file:
  - .env
  - .env.local
```

### Variables avec valeurs par défaut

```yaml
environment:
  - PORT=${PORT:-3000}
  - DEBUG=${DEBUG:-false}
```

## Networks

### Types de réseaux

```yaml
networks:
  # Bridge (défaut) - réseau isolé
  frontend:
    driver: bridge

  # Internal - pas d'accès internet
  backend:
    internal: true

  # External - réseau pré-existant
  traefik:
    external: true
```

### Utilisation

```yaml
services:
  app:
    networks:
      - frontend
      - backend
```

## Depends On

### Simple

```yaml
services:
  app:
    depends_on:
      - db
      - redis
```

### Avec condition

```yaml
services:
  app:
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
```

## Healthcheck

```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### Types de tests

```yaml
# CMD - exécute directement
test: ["CMD", "curl", "-f", "http://localhost"]

# CMD-SHELL - via shell
test: ["CMD-SHELL", "curl -f http://localhost || exit 1"]

# Désactiver
test: ["NONE"]
```

## Profiles

```yaml
services:
  app:
    profiles:
      - production

  debug:
    profiles:
      - dev
```

```bash
# Démarrer avec profil
docker compose --profile dev up -d
```

## Logging

```yaml
services:
  app:
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
```

## Resource Limits

```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

## Labels

```yaml
services:
  app:
    labels:
      - "traefik.enable=true"
      - "com.example.description=My App"
```

## Commandes Docker Compose

```bash
# Démarrer
docker compose up -d

# Arrêter
docker compose down

# Arrêter et supprimer volumes
docker compose down -v

# Logs
docker compose logs -f [service]

# Reconstruire
docker compose up -d --build

# Redémarrer un service
docker compose restart app

# Exécuter une commande
docker compose exec app bash

# Status
docker compose ps

# Mettre à jour les images
docker compose pull
```

## Variables d'environnement Docker Compose

| Variable | Description |
|----------|-------------|
| `COMPOSE_PROJECT_NAME` | Nom du projet |
| `COMPOSE_FILE` | Fichier(s) compose |
| `COMPOSE_PROFILES` | Profils actifs |
| `DOCKER_HOST` | Hôte Docker distant |

## Fichiers Compose multiples

```bash
# Merge de fichiers
docker compose -f compose.yml -f compose.override.yml up -d

# Fichier et profil
docker compose -f compose.yml --profile dev up -d
```

## Timezone

```yaml
services:
  app:
    environment:
      - TZ=Europe/Paris
    volumes:
      # Linux only
      - /etc/localtime:/etc/localtime:ro
```

## User

```yaml
services:
  app:
    user: "1000:1000"    # UID:GID
    # ou
    user: node           # Username
```

## Working Directory

```yaml
services:
  app:
    working_dir: /app
```

## Références

- [Docker Compose Specification](https://docs.docker.com/compose/compose-file/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
