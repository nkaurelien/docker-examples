# Role Ansible : Infisical (Secrets Management)

Ce rôle déploie **Infisical Standalone** via Docker Compose sur vos serveurs Linux (ex: Contabo ou autre) en exploitant vos instances **PostgreSQL et Redis / Valkey déjà existantes**.

---

## ⚙️ Variables Clés (`defaults/main.yml`)

```yaml
infisical_site_url: "https://secrets.kamitbrains.fr"
infisical_encryption_key: "..."
infisical_auth_secret: "..."

# Mutualisation de la base PostgreSQL
infisical_db_host: "passbolt-db"       # Conteneur Postgres existant
infisical_db_port: 5432
infisical_db_name: "infisical"
infisical_db_user: "postgres"
infisical_db_password: "..."

# Mutualisation du cache Redis
infisical_redis_host: "glitchtip-valkey" # Conteneur Valkey/Redis existant
infisical_redis_port: 6379
```

## 🚀 Utilisation dans un Playbook

```yaml
- hosts: contabo_server_fr
  become: true
  roles:
    - role: infisical
```
