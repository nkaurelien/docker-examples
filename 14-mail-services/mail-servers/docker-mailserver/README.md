# Intro

A production-ready fullstack but simple containerized mail server (SMTP, IMAP, LDAP, Anti-spam, Anti-virus, etc.).

Links:
- https://docker-mailserver.github.io/docker-mailserver/latest/examples/tutorials/basic-installation/
- https://github.com/docker-mailserver/docker-mailserver

# Create new User Account

```console

docker compose exec -ti mailserver setup email add admin@apps.local

```

Then login to Roundcube : `localhost:8005`