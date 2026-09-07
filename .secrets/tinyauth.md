# TinyAuth SSO Documentation & Secrets

- **Public URL**: `https://auth.kamitbrains.fr`
- **Traefik Middleware**: `tinyauth-auth@docker`

## Accounts & Secret Files

All passwords are path-referenced in gitignored files under `.secrets/`:

| Account / Username | Secret File Path |
| :--- | :--- |
| `.secrets/admin-login` | `.secrets/tinyauth-admin-password` |
| `admin` | `.secrets/tinyauth-admin-password` |
| `.secrets/user-nkaurelien-login` | `.secrets/tinyauth-user-nkaurelien-password` |
| `.secrets/user-etombe-login` | `.secrets/tinyauth-user-etombe-password` |
| `Secret Token` | `.secrets/tinyauth-secret` |


