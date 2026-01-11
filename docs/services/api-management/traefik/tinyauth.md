# TinyAuth Integration

TinyAuth est un middleware d'authentification léger pour Traefik.

## Configuration

### Labels Traefik

```yaml
labels:
  - "traefik.http.middlewares.auth.forwardauth.address=http://tinyauth:3000/auth"
  - "traefik.http.middlewares.auth.forwardauth.trustForwardHeader=true"
```

### Variables d'environnement TinyAuth

```bash
APP_URL=http://tinyauth:3000
SECRET=your-secret-key
USERS=admin:$2y$...  # bcrypt hash
```

## Utilisation

Appliquer le middleware à un service :

```yaml
labels:
  - "traefik.http.routers.myservice.middlewares=auth"
```

## Liens

- [TinyAuth GitHub](https://github.com/steveiliop56/tinyauth)
