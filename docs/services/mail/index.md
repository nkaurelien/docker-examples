# Mail Servers

Solutions de serveurs mail pour développement et production.

## Services Disponibles

### [Mailpit](mailpit.md) - Développement

Outil de test email moderne et léger :

```bash
cd mail-servers/mailpit
docker compose --profile dev up -d
# http://localhost:8025
```

### [Docker Mailserver](docker-mailserver.md) - Production

Serveur mail complet :

```bash
cd mail-servers/docker-mailserver
docker compose up -d
```

### [Mailcatcher](mailcatcher.md) - Développement

Alternative Ruby :

```bash
cd mail-servers/mailcatcher
docker compose up -d
```

## Comparatif

| Feature | Mailpit | Docker Mailserver | Mailcatcher |
|---------|---------|-------------------|-------------|
| Usage | Dev/Test | Production | Dev/Test |
| Web UI | ✅ Modern | ❌ | ✅ Simple |
| SMTP | ✅ 1025 | ✅ 25/587 | ✅ 1025 |
| IMAP/POP3 | ❌ | ✅ | ❌ |
| Persistance | ✅ SQLite | ✅ Full | ❌ Memory |
| API REST | ✅ | ❌ | ✅ |
| Dark Mode | ✅ | N/A | ❌ |

## Configuration SMTP Générique

```env
SMTP_HOST=mailpit      # ou docker-mailserver
SMTP_PORT=1025         # ou 587 pour production
SMTP_TLS=false         # true pour production
SMTP_USERNAME=
SMTP_PASSWORD=
```

## Voir Aussi

- [Mailpit README](https://github.com/nkaurelien/docker-examples/tree/main/mail-servers/mailpit)
