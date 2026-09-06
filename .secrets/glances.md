# Glances Monitoring - Identifiants d'Authentification

Ce dossier contient le secret pour l'authentification au tableau de bord Glances (`https://glances.kamitbrains.fr`).

## 📄 Fichiers associés :
* `glances-basic-auth-password` : Mot de passe généré pour l'utilisateur `admin` de Glances.

## 🚀 Utilisation dans Ansible :
Le rôle Ansible [`ansible/roles/glances`](../ansible/roles/glances) génère un hash `{SHA}` compatible avec Traefik `basicAuth` :

```yaml
glances_basic_auth_user: "admin"
glances_basic_auth_password: "{{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/glances-basic-auth-password') | trim }}"
```

## 🔐 Tester la connexion en CLI :
```bash
PASS=$(cat .secrets/glances-basic-auth-password)
curl -u "admin:$PASS" https://glances.kamitbrains.fr
```

## 🔄 Régénérer le mot de passe :
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(16))" > .secrets/glances-basic-auth-password
```
