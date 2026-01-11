# CouchDB Cluster

Base de données NoSQL documentaire avec support cluster.

## Quick Start

```bash
cd databases/couchdb-cluster
docker compose up -d
./init-cluster.sh  # Initialiser le cluster
```

## Accès

- **Fauxton UI** : http://localhost:5984/_utils

## Ports

| Service | Port | Description |
|---------|------|-------------|
| CouchDB | 5984 | API HTTP |
| HAProxy | 5984 | Load balancer (cluster) |

## Configuration Cluster

### Variables d'environnement

```bash
COUCHDB_USER=admin
COUCHDB_PASSWORD=password
COUCHDB_SECRET=secret
NODENAME=couchdb1
```

### Erlang Cookie

Tous les noeuds doivent partager le même cookie :

```yaml
environment:
  - COUCHDB_ERLANG_COOKIE=mysecretcookie
```

## Initialisation

Après démarrage des conteneurs :

```bash
./init-cluster.sh
```

## Liens

- [Documentation officielle](https://docs.couchdb.org/)
