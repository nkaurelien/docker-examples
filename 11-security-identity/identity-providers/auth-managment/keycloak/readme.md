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
├── keycloak-admin.http         # REST Client file for API testing
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

- **Clients**: `my-frontend` (OIDC + PKCE), `my-backend` (confidential + ROPC), `my-admin-service` (service account)
- **Roles**: `app-user`, `app-admin`
- **Custom Scopes**: `custom-attributes` with token mappers for `external_user_id`, `user_type`, `phone_number`, `email`, `preferred_username`
- **Security**: Brute force protection, password policy (8+ chars, digits, uppercase, special chars)
- **SMTP**: Configurable via environment variables
- **i18n**: English + French

### Realm Settings

| Setting | Value | Why |
|---------|-------|-----|
| `registrationEmailAsUsername` | `false` | Allows custom usernames (not just email) |
| `editUsernameAllowed` | `true` | Allows changing usernames via Admin API |
| `loginWithEmailAllowed` | `true` | Users can login with email or username |

> **Important**: If `registrationEmailAsUsername` is `true`, Keycloak forces `username = email` and silently ignores any username you set via the Admin API.

## User Profile (Keycloak 24+)

Keycloak 24 introduced **Declarative User Profile**. Custom attributes must be declared in the User Profile configuration, otherwise they are **silently dropped** when updating users via the Admin API (the PUT returns 204 but the attribute is not saved).

The `keycloak-init` container automatically configures these attributes:

| Attribute | View | Edit | Description |
|-----------|------|------|-------------|
| `external_user_id` | admin | admin | Link to your external database |
| `user_type` | admin | admin | User role/type classification |
| `phoneNumber` | admin, user | admin, user | Phone number |

To add new custom attributes:
1. Add the attribute to `scripts/init-user-profile.sh`
2. Add a token mapper in `realm-export.json` → `custom-attributes` scope
3. Restart: `docker compose up -d --force-recreate keycloak-init`

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

# Master realm admin — required for reliable Admin API access in KC 24+
# client_credentials on the app realm may lack full admin permissions
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=<your-admin-password>
```

### Token Verification (RS256/JWKS)

Verify tokens using the JWKS endpoint:

```
GET http://localhost:8080/realms/my-realm/protocol/openid-connect/certs
```

### Admin API Authentication (KC 24+)

Two approaches for Admin API access:

| Method | Token endpoint | Pros | Cons |
|--------|---------------|------|------|
| **Master realm ROPC** (recommended) | `POST /realms/master/.../token` with `admin-cli` + admin credentials | Full admin permissions, always works | Requires master admin password |
| **Service account client_credentials** | `POST /realms/{realm}/.../token` with `my-admin-service` | No admin password needed | May lack some permissions in KC 24+, requires `fullScopeAllowed` + realm-management roles |

> **Recommendation**: Use master realm ROPC for production backend admin operations (user creation, etc.). Use client_credentials for limited read-only operations.

### ROPC and requiredActions

When creating users programmatically for ROPC login (no browser), set:
- `emailVerified: true` — otherwise KC adds `VERIFY_EMAIL` to `requiredActions`
- `credentials[].temporary: false` — otherwise KC adds `UPDATE_PASSWORD` to `requiredActions`

Both required actions **block ROPC login** because they require a browser-based flow to complete.

### Password Grant (ROPC) for Backend Testing

The `my-backend` client supports Resource Owner Password Credentials grant for testing:

```bash
curl -X POST "http://localhost:8080/realms/my-realm/protocol/openid-connect/token" \
  -d "grant_type=password" \
  -d "client_id=my-backend" \
  -d "client_secret=BACKEND_SECRET" \
  -d "username=user@example.com" \
  -d "password=userpassword"
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

### Login Form Label

The login form input label depends on realm settings:
- If `registrationEmailAsUsername: true` → Keycloak uses the `email` message key
- If `registrationEmailAsUsername: false` → Keycloak uses the `usernameOrEmail` message key

Customize in `themes/my-app/login/messages/messages_en.properties`:
```properties
usernameOrEmail=Username or email address
```

### Realm

Edit `realm-export.json` to:
- Add/remove clients
- Change roles
- Modify password policy
- Add identity providers (Google, GitHub, etc.)

> **Note**: `realm-export.json` is only imported on **first start** (`--import-realm` flag). To change settings on a running instance, use the Admin API or the admin console.

### Providers

Drop custom Keycloak provider JARs into `providers/` directory.

## Production Deployment

For production behind a reverse proxy (Nginx):

1. Change `start-dev` to `start` in docker-compose.yml command
2. Bind Keycloak to `127.0.0.1:8080` (change port mapping in compose)
3. Set `KEYCLOAK_HOSTNAME=auth.yourdomain.com`
4. Configure Nginx with TLS termination and proxy to `127.0.0.1:8080`
5. Important: allow `/.well-known` in Nginx if you block hidden files:
   ```nginx
   location ~ /\.(?!well-known) {
       deny all;
   }
   ```

## API Testing

Use `keycloak-admin.http` with the REST Client extension (VS Code) or IntelliJ HTTP Client. It includes:

- Admin authentication
- Realm settings (registrationEmailAsUsername, editUsernameAllowed)
- User CRUD with custom attributes
- User Profile configuration
- Role management
- Client management and secrets
- OIDC discovery, JWKS, ROPC, token introspection
- Service account token exchange
- Events and audit logs

## References

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [Keycloak Docker Guide](https://www.keycloak.org/getting-started/getting-started-docker)
- [Keycloak Theme Development](https://www.keycloak.org/docs/latest/server_development/#_themes)
- [Keycloak Admin REST API](https://www.keycloak.org/docs-api/latest/rest-api/)