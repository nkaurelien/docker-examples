# Let's Encrypt SSL

Configuration SSL automatique avec Let's Encrypt pour Traefik.

## Configuration

### traefik.yml

```yaml
certificatesResolvers:
  letsencrypt:
    acme:
      email: your-email@example.com
      storage: /letsencrypt/acme.json
      httpChallenge:
        entryPoint: web
```

### Labels pour un service

```yaml
labels:
  - "traefik.http.routers.myservice.tls=true"
  - "traefik.http.routers.myservice.tls.certresolver=letsencrypt"
```

## Volumes

```yaml
volumes:
  - ./letsencrypt:/letsencrypt
```

## Staging vs Production

Pour les tests, utilisez le serveur staging :

```yaml
caServer: https://acme-staging-v02.api.letsencrypt.org/directory
```

## Liens

- [Traefik ACME](https://doc.traefik.io/traefik/https/acme/)
- [Let's Encrypt](https://letsencrypt.org/)
