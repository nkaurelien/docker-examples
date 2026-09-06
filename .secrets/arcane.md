# Arcane Docker Manager - Clés et Secrets

Ce dossier contient les clés de chiffrement et de signature JWT pour le gestionnaire PaaS Arcane.

## 📄 Fichiers associés :
* `arcane-jwt-secret` : Clé secrète hexadécimale de 64 caractères (32 octets) utilisée pour la signature des jetons de session JWT Arcane.
* `arcane-encryption-key` : Clé secrète hexadécimale de 64 caractères (32 octets) utilisée pour le chiffrement des données sensibles stockées en base SQLite.

## 🚀 Utilisation dans Ansible :
Le rôle Ansible [`ansible/roles/arcane`](../ansible/roles/arcane) injecte ces variables dans le conteneur Arcane :

```yaml
environment:
  - JWT_SECRET={{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/arcane-jwt-secret') | trim }}
  - ENCRYPTION_KEY={{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/arcane-encryption-key') | trim }}
```

## 🔄 Générer/Renouveler une nouvelle clé :
```bash
python3 -c "import secrets; print(secrets.token_hex(32))" > .secrets/arcane-jwt-secret
python3 -c "import secrets; print(secrets.token_hex(32))" > .secrets/arcane-encryption-key
```
