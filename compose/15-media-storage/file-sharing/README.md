# Erugo

Self-hosted file sharing platform built with PHP/Laravel and Vue.js.

## Quick Start

```bash
docker compose up -d
```

Access at: http://localhost:9998

## Features

- Secure file sharing
- Self-hosted (your data, your rules)
- Elegant UI with Vue.js frontend
- MIT licensed open source

## Configuration

Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
```

## SSL avec Nginx

Un exemple de configuration Nginx avec SSL est disponible dans `nginx-ssl.conf.example`.

Pour l'utiliser avec le projet [nginx-certbot](../../nginx-certbot/):

```bash
# 1. Générer le certificat
cd ../nginx-certbot
make nginx-start
make cert DOMAIN=erugo.example.com EMAIL=admin@example.com
make nginx-stop

# 2. Copier la config
cp ../file-sharing/erugo/nginx-ssl.conf.example nginx/conf.d/erugo.conf

# 3. Adapter le domaine dans erugo.conf

# 4. Démarrer
make up
```

## Links

- [GitHub](https://github.com/wardy784/erugo)
- [Docker Hub](https://hub.docker.com/r/wardy784/erugo)
