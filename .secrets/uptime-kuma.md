# Uptime Kuma Status Page - Identifiants d'Authentification

Ce dossier contient le mot de passe pour le compte administrateur Uptime Kuma (`https://status.kamitbrains.fr`).

## 👤 Compte Administrateur Uptime Kuma :
* **URL** : `https://status.kamitbrains.fr`
* **Nom d'utilisateur** : `admin`
* **Mot de passe** : *(voir le passfile `.secrets/uptime-kuma-admin-password`)*

## 📄 Fichiers associés :
* `uptime-kuma-admin-password` : Mot de passe généré pour le compte `admin` lors de la création du compte administrateur.

## 🔄 Régénérer un nouveau mot de passe :
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(16))" > .secrets/uptime-kuma-admin-password
```
