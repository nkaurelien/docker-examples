# Arcane Docker Manager - Clés et Secrets

Ce dossier contient les clés de chiffrement, de signature JWT, l'adresse email et le mot de passe admin par défaut pour le gestionnaire PaaS Arcane.

## 👤 Compte Admin par défaut :
```text
# arcane-admin — compte admin par defaut du manager Arcane
#
# username : arcane
# email    : admin@kamitbrains.fr (ou configurable via .secrets/arcane-admin-email)
# password : arcane-admin        (DEFAUT — A CHANGER au 1er login)
```

## 📄 Fichiers associés :
* `arcane-admin-email` : Email de l'administrateur (par défaut `admin@kamitbrains.fr`), injecté dynamiquement par le service seeder `arcane-db-seeder`.
* `arcane-admin-password` : Mot de passe d'administration par défaut (`arcane-admin` ou généré) à utiliser lors du premier accès sur `https://arcane.kamitbrains.fr`.
* `arcane-jwt-secret` : Clé secrète hexadécimale de 64 caractères (32 octets) utilisée pour la signature des jetons de session JWT Arcane.
* `arcane-encryption-key` : Clé secrète hexadécimale de 64 caractères (32 octets) utilisée pour le chiffrement des données sensibles stockées en base SQLite.

## 🚀 Utilisation dans Ansible :
Le rôle Ansible [`ansible/roles/arcane`](../ansible/roles/arcane) injecte les clés d'environnement et exécute `arcane-db-seeder` pour seeder les registres et l'adresse email de l'administrateur :

```yaml
arcane_admin_email: "{{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/arcane-admin-email', errors='ignore') | default('admin@kamitbrains.fr', true) | trim }}"
```

## 🔄 Générer/Renouveler une nouvelle clé :
```bash
python3 -c "import secrets; print(secrets.token_hex(32))" > .secrets/arcane-jwt-secret
python3 -c "import secrets; print(secrets.token_hex(32))" > .secrets/arcane-encryption-key
```
