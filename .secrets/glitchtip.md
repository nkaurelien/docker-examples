# GlitchTip Error Tracking & APM - Secrets & Credentials

Ce dossier contient les mots de passe et clés secrètes pour le service GlitchTip.

---

## 👤 Compte Admin par défaut :
- **URL** : `https://glitchtip.kamitbrains.fr`
- **Login File** : `.secrets/glitchtip-admin-login`
- **Mot de passe** : (voir `.secrets/glitchtip-admin-password`)

---

## 📄 Fichiers associés :
* `glitchtip-admin-login` : Identifiant email administrateur pour l'accès web.
* `glitchtip-admin-password` : Mot de passe administrateur pour l'accès web sur `https://glitchtip.kamitbrains.fr`.
* `glitchtip-db-password` : Mot de passe de la base de données PostgreSQL 17 (`glitchtip-db`).
* `glitchtip-secret-key` : Clé secrète hexadécimale de 64 caractères utilisée pour Django.

---

## 🚀 Utilisation dans Ansible :
Le rôle Ansible [`ansible/roles/glitchtip`](../ansible/roles/glitchtip) injecte ces clés dans `docker-compose.yml.j2` :

```yaml
glitchtip_admin_email: "{{ lookup('file', playbook_dir + '/../.secrets/glitchtip-admin-login') | trim }}"
glitchtip_admin_password: "{{ lookup('file', playbook_dir + '/../.secrets/glitchtip-admin-password') | trim }}"
glitchtip_db_password: "{{ lookup('file', playbook_dir + '/../.secrets/glitchtip-db-password') | trim }}"
glitchtip_secret_key: "{{ lookup('file', playbook_dir + '/../.secrets/glitchtip-secret-key') | trim }}"
```
