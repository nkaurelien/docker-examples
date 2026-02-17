# Keycloak Docker Setup

Production-ready Keycloak (v24) with PostgreSQL, custom themes, realm auto-import, and user profile initialization.

## Quick Start

```bash
cp .env.example .env
# Edit .env with your passwords
docker compose up -d
```

Keycloak will be available at `http://localhost:8080`

## What's Included

```
keycloak/
├── docker-compose.yml          # Keycloak + PostgreSQL + init container
├── .env.example                # Environment variables template
├── realm-export.json           # Realm config (auto-imported on first start)
├── scripts/
│   └── init-user-profile.sh    # Custom user profile attributes setup
├── themes/my-app/              # Custom theme (login, account, email)
│   ├── login/                  # Login page theme (CSS, i18n messages)
│   ├── account/                # Account management theme
│   └── email/                  # Email templates (HTML + plain text)
└── providers/                  # Custom Keycloak providers (JARs)
```

## Architecture

| Service | Description | Port |
|---------|-------------|------|
| `keycloak` | Identity Provider | 8080 |
| `keycloak-db` | PostgreSQL database | internal |
| `keycloak-init` | User profile setup (runs once) | - |

## Pre-configured Realm

The `realm-export.json` creates a realm with:

- **Clients**: `my-frontend` (OIDC + PKCE), `my-backend` (bearer-only), `my-admin-service` (service account)
- **Roles**: `app-user`, `app-admin`
- **Custom Scopes**: `custom-attributes` with token mappers for `external_user_id`, `user_type`, `phone_number`
- **Security**: Brute force protection, password policy (8+ chars, digits, uppercase, special chars)
- **SMTP**: Configurable via environment variables
- **i18n**: English + French

## Integration

### Frontend (Next.js / NextAuth.js)

```env
KEYCLOAK_CLIENT_ID=my-frontend
KEYCLOAK_CLIENT_SECRET=<from-keycloak-admin>
KEYCLOAK_ISSUER=http://localhost:8080/realms/my-realm
```

### Backend (FastAPI / Express)

```env
KEYCLOAK_SERVER_URL=http://localhost:8080
KEYCLOAK_REALM=my-realm
KEYCLOAK_CLIENT_ID=my-backend
KEYCLOAK_CLIENT_SECRET=<from-keycloak-admin>
KEYCLOAK_ADMIN_CLIENT_ID=my-admin-service
KEYCLOAK_ADMIN_CLIENT_SECRET=<from-keycloak-admin>
```

### Get Client Secrets

After first start, retrieve secrets from the admin console or via API:

```bash
# Get admin token
TOKEN=$(curl -s -X POST "http://localhost:8080/realms/master/protocol/openid-connect/token" \
  --data-urlencode "grant_type=password" \
  --data-urlencode "client_id=admin-cli" \
  --data-urlencode "username=admin" \
  --data-urlencode "password=YOUR_ADMIN_PASSWORD" \
  | jq -r '.access_token')

# Get client secret
CLIENT_UUID=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/admin/realms/my-realm/clients?clientId=my-frontend" \
  | jq -r '.[0].id')

curl -s -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/admin/realms/my-realm/clients/$CLIENT_UUID/client-secret" \
  | jq -r '.value'
```

## Customization

### Theme

Replace files in `themes/my-app/` with your branding:
- `login/resources/css/login.css` — Login page styles
- `login/resources/img/` — Logo, background images
- `login/messages/` — i18n text (en, fr)
- `email/html/template.ftl` — Email HTML template
- `email/messages/` — Email text (en, fr)

### Realm

Edit `realm-export.json` to:
- Add/remove clients
- Change roles
- Modify password policy
- Add identity providers (Google, GitHub, etc.)

### Providers

Drop custom Keycloak provider JARs into `providers/` directory.

## Production Deployment

For production behind a reverse proxy (Nginx):

1. Bind Keycloak to `127.0.0.1:8080` (change port mapping in compose)
2. Set `KEYCLOAK_HOSTNAME=auth.yourdomain.com`
3. Configure Nginx with TLS termination and proxy to `127.0.0.1:8080`
4. Important: allow `/.well-known` in Nginx if you block hidden files:
   ```nginx
   location ~ /\.(?!well-known) {
       deny all;
   }
   ```

## References

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [Keycloak Docker Guide](https://www.keycloak.org/getting-started/getting-started-docker)
- [Keycloak Theme Development](https://www.keycloak.org/docs/latest/server_development/#_themes)
