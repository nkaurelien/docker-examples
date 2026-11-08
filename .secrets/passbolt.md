# Passbolt Team Password Manager

Rôle : `ansible/roles/passbolt` (valeurs génériques ; les valeurs réelles vivent dans le dépôt d'infra privé).

- **Public URL** : `https://passwords.<domaine>` (`passbolt_hostname`)
- **Database Engine** : PostgreSQL 16 Alpine (`postgres:16-alpine`)
- **Admin** : `passbolt_admin_email` (défaut `admin@<passbolt_domain>`)

## Fichiers secrets (dans `passbolt_secrets_dir`, défaut `<playbook>/../.secrets`)

| Fichier | Contenu |
|---|---|
| `passbolt-db-password` | mot de passe PostgreSQL |
| `passbolt-smtp-login` | login SMTP (optionnel) |
| `passbolt-smtp-password` | mot de passe / clé SMTP (optionnel) |

L'envoi d'e-mails n'est activé que si `passbolt_smtp_host` et les deux fichiers SMTP sont renseignés.

## Activation Link & Logs

```bash
docker logs passbolt-init
```
