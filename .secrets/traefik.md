# Traefik Dashboard - Identifiants d'Authentification

Ce dossier contient le secret pour l'authentification au tableau de bord Traefik (`https://traefik.kamitbrains.fr`).

## 📄 Fichiers associés :
* `traefik-dashboard-basic-auth-password` : Mot de passe généré pour l'utilisateur `admin` du dashboard Traefik.

## 🚀 Utilisation dans Ansible :
Le rôle Ansible [`ansible/roles/traefik`](../ansible/roles/traefik) génère un middleware `basicAuth` :

```yaml
traefik_dashboard_basic_auth_user: "admin"
traefik_dashboard_basic_auth_password: "{{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/traefik-dashboard-basic-auth-password') | trim }}"
```

## 🔐 Tester la connexion en CLI :
```bash
PASS=$(cat .secrets/traefik-dashboard-basic-auth-password)
curl -u "admin:$PASS" https://traefik.kamitbrains.fr
```

## 🔄 Régénérer le mot de passe :
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(16))" > .secrets/traefik-dashboard-basic-auth-password
```
