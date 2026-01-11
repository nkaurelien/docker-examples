# Security

Outils de sécurité pour environnements Docker.

## Services Disponibles

### [NeuVector](neuvector.md)

Plateforme de sécurité container complète :

- Runtime protection
- Network security
- Vulnerability scanning
- Compliance checking

```bash
cd security/neuvector
docker compose up -d
# https://localhost:8443 (admin/admin)
```

### [Docker Socket Proxy](socket-proxy.md)

Proxy sécurisé pour l'API Docker :

- Accès granulaire au Docker socket
- Permissions configurables
- Isolation réseau

```bash
# Intégré dans les variantes *.socket-proxy.yml
docker compose -f compose.socket-proxy.yml up -d
```

## Bonnes Pratiques

### 1. Ne jamais exposer le Docker socket directement

```yaml
# ❌ Mauvais
volumes:
  - /var/run/docker.sock:/var/run/docker.sock

# ✅ Bon - via socket-proxy
services:
  socket-proxy:
    image: tecnativa/docker-socket-proxy
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
```

### 2. Utiliser des réseaux internes

```yaml
networks:
  socket-proxy:
    internal: true  # Pas d'accès internet
```

### 3. Principe du moindre privilège

```yaml
cap_add:
  - NET_ADMIN  # Seulement ce qui est nécessaire
cap_drop:
  - ALL        # Supprimer tout par défaut
```

### 4. Volumes en read-only

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock:ro
  - /proc:/host/proc:ro
```

## Voir Aussi

- [Docker Capabilities](../../docker/capabilities.md)
- [Socket Proxy Permissions](../../reference/socket-proxy-permissions.md)
