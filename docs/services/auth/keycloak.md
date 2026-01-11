# Keycloak

Solution open-source de gestion d'identité et d'accès (IAM).

## Quick Start

```bash
cd auth-managment/keycloak
docker compose up -d
```

## Accès

- **Admin Console** : http://localhost:8080
- **Credentials par défaut** : admin / admin

## Ports

| Service | Port | Description |
|---------|------|-------------|
| Keycloak | 8080 | Web UI & API |

## Configuration

### Variables d'environnement

```bash
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin
KC_DB=postgres
KC_DB_URL=jdbc:postgresql://postgres:5432/keycloak
KC_DB_USERNAME=keycloak
KC_DB_PASSWORD=password
```

## Fonctionnalités

- SSO (Single Sign-On)
- OAuth 2.0 / OpenID Connect
- SAML 2.0
- LDAP / Active Directory
- Social login (Google, GitHub, etc.)

## Liens

- [Documentation officielle](https://www.keycloak.org/documentation)
