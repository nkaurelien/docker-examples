# Nginx + Certbot (Let's Encrypt)

Reverse proxy Nginx avec gestion automatique des certificats SSL via Certbot/Let's Encrypt.

## Quick Start

### 1. Configuration

Éditer les fichiers de configuration :

```bash
# Modifier le domaine dans nginx/conf.d/default.conf
# Remplacer "example.com" par votre domaine

# Modifier init-letsencrypt.sh
# - domains=(votre-domaine.com www.votre-domaine.com)
# - email="votre-email@example.com"
```

### 2. Première initialisation

```bash
# Générer le premier certificat
./init-letsencrypt.sh
```

### 3. Démarrage

```bash
docker compose up -d
```

## Fonctionnement

- **Nginx** : Reverse proxy avec SSL termination
- **Certbot** : Renouvellement automatique des certificats (toutes les 12h)
- **Auto-reload** : Nginx recharge la config toutes les 6h

## Structure

```
nginx-certbot/
├── compose.yml
├── init-letsencrypt.sh      # Script d'initialisation
├── nginx/
│   └── conf.d/
│       └── default.conf     # Configuration Nginx
└── certbot/
    ├── conf/                # Certificats Let's Encrypt
    └── www/                 # Challenge ACME
```

## Ajouter un nouveau site

1. Créer un fichier dans `nginx/conf.d/` (ex: `mysite.conf`)
2. Ajouter le domaine dans `init-letsencrypt.sh`
3. Relancer le script d'initialisation

### Exemple de configuration proxy

```nginx
server {
    listen 80;
    server_name myapp.example.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name myapp.example.com;

    ssl_certificate /etc/letsencrypt/live/myapp.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/myapp.example.com/privkey.pem;

    location / {
        proxy_pass http://myapp:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Mode staging

Pour les tests, utilisez le serveur staging de Let's Encrypt pour éviter les rate limits :

```bash
# Dans init-letsencrypt.sh
staging=1
```

## Liens

- [Certbot Documentation](https://certbot.eff.org/docs/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Nginx Documentation](https://nginx.org/en/docs/)
