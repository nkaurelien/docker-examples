# TinyAuth SSO Documentation & Secrets

- **Public URL**: `https://auth.example.com`
- **Traefik Middleware**: `tinyauth-auth@docker`

## Accounts & Secret Files

All logins and passwords are path-referenced in gitignored files under `.secrets/`:

| Account Description | Login File Path | Secret File Path |
| :--- | :--- | :--- |
| Admin SSO Account | `.secrets/tinyauth-admin-login` | `.secrets/tinyauth-admin-password` |
| User Account (deploy) | `.secrets/tinyauth-user-deploy-login` | `.secrets/tinyauth-user-deploy-password` |
| User Account (user2) | `.secrets/tinyauth-user-user2-login` | `.secrets/tinyauth-user-user2-password` |
| Secret Token | N/A | `.secrets/tinyauth-secret` |
