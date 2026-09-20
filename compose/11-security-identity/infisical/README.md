# Infisical Standalone Stack

Stack Docker Compose officielle pour exécuter [Infisical](https://infisical.com/docs/self-hosting/deployment-options/standalone-infisical) (gestionnaire de secrets et variables d'environnement).

---

## 🎯 Architecture

- **Infisical Core** : UI Web et API REST sur port `8080`.
- **PostgreSQL 16** : Stockage persistant des secrets chiffrés et journaux d'audit.
- **Redis 7** : File d'attente asynchrone et cache de sessions.

## 🚀 Démarrage Rapide

```bash
cp .env.example .env

# Générer vos propres clés de chiffrement
# ENCRYPTION_KEY : openssl rand -hex 16
# AUTH_SECRET    : openssl rand -base64 32

docker compose up -d
```

## 🔄 Mutualisation de PostgreSQL et Redis (Optionnel)

Si vous possédez déjà une instance PostgreSQL et Redis (ou Valkey) sur votre machine ou serveur hôte :
1. Commentez les services `infisical-db` et `infisical-redis` dans `docker-compose.yml`.
2. Ajustez `DB_CONNECTION_URI` et `REDIS_URL` dans votre `.env` pour pointer vers vos services existants.
