# TinyAuth SSO Documentation & Secrets

- **Public URL**: `https://auth.kamitbrains.fr`
- **Traefik Middleware**: `tinyauth-auth@docker`

## Accounts & Secret Files

All passwords are path-referenced in gitignored files under `.secrets/`:

| Account / Username | Secret File Path |
| :--- | :--- |
| `admin@kamitbrains.fr` | `.secrets/tinyauth-admin-password` |
| `admin` | `.secrets/tinyauth-admin-password` |
| `nkaurelien@gmail.com` | `.secrets/tinyauth-user-nkaurelien-password` |
| `etombe_ndedi@hotmail.fr` | `.secrets/tinyauth-user-etombe-password` |
| `Secret Token` | `.secrets/tinyauth-secret` |


