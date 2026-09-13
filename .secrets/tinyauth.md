# TinyAuth SSO Documentation & Secrets

- **Public URL**: `https://auth.kamitbrains.fr`
- **Traefik Middleware**: `tinyauth-auth@docker`

## Accounts & Secret Files

All logins and passwords are path-referenced in gitignored files under `.secrets/`:

| Account Description | Login File Path | Secret File Path |
| :--- | :--- | :--- |
| Admin SSO Account | `.secrets/tinyauth-admin-login` | `.secrets/tinyauth-admin-password` |
| User Account (nkaurelien) | `.secrets/tinyauth-user-nkaurelien-login` | `.secrets/tinyauth-user-nkaurelien-password` |
| User Account (etombe) | `.secrets/tinyauth-user-etombe-login` | `.secrets/tinyauth-user-etombe-password` |
| Secret Token | N/A | `.secrets/tinyauth-secret` |
