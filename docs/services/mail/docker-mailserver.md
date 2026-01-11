# Docker Mailserver

Serveur mail complet (SMTP, IMAP, anti-spam) pour la production.

## Quick Start

```bash
cd mail-servers/docker-mailserver
docker compose up -d
```

## Ports

| Service | Port | Description |
|---------|------|-------------|
| SMTP | 25 | Mail transfer |
| SMTP Submission | 587 | Mail submission (TLS) |
| IMAP | 143 | Mail retrieval |
| IMAPS | 993 | Mail retrieval (SSL) |

## Configuration

### Variables d'environnement

```bash
HOSTNAME=mail.example.com
DOMAINNAME=example.com
ENABLE_SPAMASSASSIN=1
ENABLE_CLAMAV=1
```

### Ajouter un utilisateur

```bash
docker exec -it mailserver setup email add user@example.com
```

## Liens

- [Documentation officielle](https://docker-mailserver.github.io/docker-mailserver/)
