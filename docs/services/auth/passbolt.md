# Passbolt

Gestionnaire de mots de passe open-source pour équipes.

## Quick Start

```bash
cd auth-managment/passbolt
docker compose up -d
```

## Accès

- **URL** : https://passbolt.local (configurer DNS local)
- **Premier accès** : Créer un admin via CLI

```bash
docker exec -it passbolt su -m -c \
  "/usr/share/php/passbolt/bin/cake passbolt register_user \
  -u admin@example.com -f Admin -l User -r admin" -s /bin/sh www-data
```

## Ports

| Service | Port | Description |
|---------|------|-------------|
| HTTP | 80 | Redirection HTTPS |
| HTTPS | 443 | Interface web |

## Configuration

### Variables d'environnement

```bash
# URL de l'application
APP_FULL_BASE_URL=https://passbolt.local

# Base de données PostgreSQL
DATASOURCES_DEFAULT_DRIVER=Cake\Database\Driver\Postgres
DATASOURCES_DEFAULT_URL=postgres://passbolt:P4ssb0lt@db:5432/passbolt?schema=passbolt

# Email (SMTP)
EMAIL_TRANSPORT_DEFAULT_HOST=smtp.domain.tld
EMAIL_TRANSPORT_DEFAULT_PORT=587
EMAIL_TRANSPORT_DEFAULT_USERNAME=
EMAIL_TRANSPORT_DEFAULT_PASSWORD=
EMAIL_TRANSPORT_DEFAULT_TLS=true
```

### Volumes

| Volume | Description |
|--------|-------------|
| `gpg_volume` | Clés GPG du serveur |
| `jwt_volume` | Tokens JWT |
| `database_volume` | Données PostgreSQL |

## Fonctionnalités

- Stockage sécurisé des mots de passe (chiffrement GPG)
- Partage d'identifiants en équipe
- Extension navigateur (Firefox, Chrome)
- Application mobile
- API REST
- Import/Export (CSV, KeePass, LastPass)
- Authentification MFA

## SSL/TLS

Pour un certificat personnalisé, décommenter les volumes :

```yaml
volumes:
  - ./cert.pem:/etc/ssl/certs/certificate.crt:ro
  - ./key.pem:/etc/ssl/certs/certificate.key:ro
```

## Image Non-Root

Pour plus de sécurité, utiliser l'image non-root :

```yaml
image: passbolt/passbolt:latest-ce-non-root
ports:
  - "80:8080"
  - "443:4433"
```

## Liens

- [Documentation officielle](https://help.passbolt.com/)
- [GitHub](https://github.com/passbolt/passbolt_docker)
