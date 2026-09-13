---
tags: databases
---

# Databases & Data Stores

Solutions de bases de données et magasins de données containerisés.

## Services disponibles

| Service | Type | Description |
|---------|------|-------------|
| [PostgreSQL](postgresql.md) | SQL | Base de données relationnelle (Transactions ACID) |
| [CouchDB Cluster](couchdb.md) | NoSQL | Base de données documentaire distribuée |
| [Valkey / Redis / etcd](valkey-redis-etcd.md) | In-Memory / Key-Value | Comparatif et guide d'architecture (Cache, Task Queue, Consensus) |

## Choisir une solution

- **PostgreSQL** : SQL standard, transactions ACID, extensions riches
- **Valkey (compatible Redis)** : In-memory cache ultra-rapide, queues Celery/workers, pub/sub
- **CouchDB** : Documents JSON, réplication multi-master, offline-first
- **etcd** : Consistance stricte Raft pour orchestration de cluster et Kubernetes
