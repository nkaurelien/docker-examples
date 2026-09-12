# Index des Secrets du Projet

Le dossier `.secrets/` contient l'ensemble des jetons d'API, mots de passe et clés cryptographiques utilisés par **Ansible**, le **SDK Cloudflare** et nos stacks **Docker**.

> ⚠️ **Sécurité** : Le dossier `.secrets/` est strictement ignoré par Git via le fichier `.gitignore`. Aucun secret ne doit jamais être commité en clair dans le dépôt.

---

## 📋 Inventaire des secrets et documentation associée

| Composant | Fichiers de secrets | Fichier de documentation |
|---|---|---|
| **Serveur Contabo SSH** | `ssh-contabo-server-ip`<br>`ssh-contabo-server-user-login`<br>`ssh-contabo-server-password` | [**`ssh-contabo.md`**](./ssh-contabo.md) |
| **Serveur Homelab SSH** | `ssh-kamitbrains-homelab-fqdn`<br>`ssh-kamitbrains-homelab-ip`<br>`ssh-kamitbrains-homelab-mac`<br>`ssh-kamitbrains-homelab-user-login`<br>`ssh-kamitbrains-homelab-password` | [**`ssh-kamitbrains-homelab.md`**](./ssh-kamitbrains-homelab.md) |
| **API Cloudflare** | `cloudflare-account-id`<br>`cloudflare-api-key` | [**`cloudflare.md`**](./cloudflare.md) |
| **Arcane PaaS Manager** | `arcane-jwt-secret`<br>`arcane-encryption-key` | [**`arcane.md`**](./arcane.md) |
| **Glances Monitoring** | `glances-basic-auth-password` | [**`glances.md`**](./glances.md) |
| **Ntfy Notification Service** | `ntfy-admin-password`<br>`ntfy-topic` | [**`ntfy.md`**](./ntfy.md) |


---

## 🛠️ Génération automatique des secrets manquants

Pour régénérer ou créer les secrets manquants en une ligne Python :

```bash
python3 -c "
import secrets, os
s = '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets'
open(f'{s}/arcane-jwt-secret', 'w').write(secrets.token_hex(32) + '\n')
open(f'{s}/arcane-encryption-key', 'w').write(secrets.token_hex(32) + '\n')
open(f'{s}/glances-basic-auth-password', 'w').write(secrets.token_urlsafe(16) + '\n')
print('Secrets générés avec succès.')
"
```
