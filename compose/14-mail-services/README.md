# Mail Services

Email servers, testing tools, and mail-related services.

## Existing Projects

- **mail-servers/** - Email server solutions (Docker Mailserver, Mailcatcher, Mailu)

## Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Docker Mailserver** | Full-featured mail server | [docker-mailserver/docker-mailserver](https://github.com/docker-mailserver/docker-mailserver) |
| **Mailu** | Simple mail server | [Mailu/Mailu](https://github.com/Mailu/Mailu) |
| **Mailcow** | Docker mail server suite | [mailcow/mailcow-dockerized](https://github.com/mailcow/mailcow-dockerized) |
| **Postal** | Mail delivery platform | [postalserver/postal](https://github.com/postalserver/postal) |
| **Modoboa** | Mail hosting platform | [modoboa/modoboa](https://github.com/modoboa/modoboa) |
| **iRedMail** | Full-featured mail server | [iredmail/iRedMail](https://github.com/iredmail/iRedMail) |
| **Listmonk** | Mailing list manager | [knadh/listmonk](https://github.com/knadh/listmonk) |
| **Mailcatcher** | SMTP testing tool | [sj26/mailcatcher](https://github.com/sj26/mailcatcher) |
| **MailHog** | Email testing tool | [mailhog/MailHog](https://github.com/mailhog/MailHog) |
| **Inbucket** | Disposable email testing | [inbucket/inbucket](https://github.com/inbucket/inbucket) |
| **Roundcube** | Webmail client | [roundcube/roundcubemail](https://github.com/roundcube/roundcubemail) |
| **Rainloop** | Modern webmail | [RainLoop/rainloop-webmail](https://github.com/RainLoop/rainloop-webmail) |
| **Cypht** | Webmail aggregator | [cypht-org/cypht](https://github.com/cypht-org/cypht) |
| **Maddy** | Composable mail server | [foxcpp/maddy](https://github.com/foxcpp/maddy) |

## Quick Start

```bash
cd mail-servers/mailcatcher/
docker compose up -d
```

Access Mailcatcher at `http://mail.apps.local`.
