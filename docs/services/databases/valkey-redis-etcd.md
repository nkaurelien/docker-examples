---
tags: databases, valkey, redis, etcd, architecture, caching, in-memory, consensus
---

# Comparatif & Architecture : Valkey vs Redis vs etcd

Fiche comparative des technologies In-Memory Data Store et Key-Value Store utilisées dans l'infrastructure (`docker-examples`).

---

## 1. Valkey vs Redis (Fork Open Source BSD)

| Critère | Valkey | Redis |
| :--- | :--- | :--- |
| **Licence** | **Open Source pure (BSD 3-Clause)** | Propriétaire / Commerciale (SSPLv2 / RSALv2 depuis mars 2024) |
| **Gouvernance** | **Linux Foundation** (AWS, Google, Red Hat, Ericsson, Snap) | Redis Inc. (Entreprise privée) |
| **Compatibilité** | **Drop-in replacement 100% compatible** avec Redis | Origine |
| **Port / Protocole** | Port `6379` / Protocole RESP | Port `6379` / Protocole RESP |
| **Cas d'usage** | Cache en mémoire, queues Celery/Task Workers, Pub/Sub, sessions | Cache en mémoire, queues, Pub/Sub |

> 💡 **Remarque** : Valkey est utilisé comme moteur in-memory par défaut dans nos stacks (ex: GlitchTip) pour conserver une licence BSD libre et pérenne.

---

## 2. Valkey / Redis vs etcd (In-Memory Cache vs Consensus Raft)

| Critère | Valkey / Redis | etcd |
| :--- | :--- | :--- |
| **Objectif principal** | **Vitesse extrême (Sub-millisecond latency)** | **Fiabilité & Consistance stricte (Strong Consistency)** |
| **Stockage** | En **RAM** (In-Memory) avec persistance optionnelle | Sur **Disque** (B+Tree) avec cache RAM |
| **Consensus / Modèle** | Loop d'événements asynchrone (Event Loop) | Algorithme de consensus **Raft** (Quorum de nœuds) |
| **Cas d'usage clé** | Caching Web, Queues Celery/Workers, Pub/Sub, Sessions | **Stockage d'état Kubernetes**, Découverte de services, Configs d'infra critiques |
| **Performance** | Des centaines de milliers d'ops/sec | Écritures synchrones sécurisées avec quorum Raft |

---

## 3. Matrice de Décision Architecture

- **Utiliser Valkey (ou Redis)** : Pour du cache web, de la gestion de session HTTP, des files de tâches d'arrière-plan (Celery, BullMQ, RQ), ou du pub/sub temps réel.
- **Utiliser etcd** : Pour stocker la configuration d'état critique de clusters (ex: control-plane Kubernetes, secours HA, verrouillage distribué fort).
- **Utiliser PostgreSQL** : Pour le stockage relationnel principal avec transactions ACID.
