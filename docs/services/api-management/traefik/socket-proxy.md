# Docker Socket Proxy

Sécurise l'accès au socket Docker pour Traefik.

## Pourquoi ?

Exposer `/var/run/docker.sock` directement est un risque de sécurité. Le socket proxy limite les permissions.

## Configuration

### compose.yml

```yaml
services:
  socket-proxy:
    image: tecnativa/docker-socket-proxy
    environment:
      CONTAINERS: 1
      NETWORKS: 1
      SERVICES: 1
      TASKS: 1
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - socket-proxy

  traefik:
    environment:
      - DOCKER_HOST=tcp://socket-proxy:2375
    depends_on:
      - socket-proxy
    networks:
      - socket-proxy
```

## Permissions

Voir [Socket Proxy Permissions](../../../reference/socket-proxy-permissions.md) pour la liste complète des options.

## Liens

- [tecnativa/docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy)
