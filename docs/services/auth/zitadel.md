# Zitadel

Plateforme cloud-native de gestion d'identité.

## Quick Start

```bash
cd auth-managment/zitadel
docker compose up -d
```

## Accès

- **Console** : http://localhost:8080
- **Credentials** : Voir les logs au premier démarrage

## Ports

| Service | Port | Description |
|---------|------|-------------|
| Zitadel | 8080 | Web UI & API |

## Configuration

### Variables d'environnement

```bash
ZITADEL_MASTERKEY=MasterkeyNeedsToHave32Characters
ZITADEL_DATABASE_POSTGRES_HOST=postgres
ZITADEL_DATABASE_POSTGRES_DATABASE=zitadel
```

## Fonctionnalités

- Multi-tenant
- OAuth 2.0 / OpenID Connect
- SAML
- Passwordless (FIDO2/WebAuthn)
- API-first design

## Liens

- [Documentation officielle](https://zitadel.com/docs)
- [GitHub](https://github.com/zitadel/zitadel)
