---
tags: databases, docker-compose, valkey, redis, postgresql
---

# Databases

Database management systems, clusters, and data persistence solutions.

## Existing Projects

- **databases/valkey/** - Valkey 9 In-Memory Data Store (Open source BSD Redis fork)
- **databases/redis/** - Redis 7 In-Memory Data Store
- **databases/postgres/** - PostgreSQL Relational Database
- **databases/couchdb-cluster/** - CouchDB Document Cluster
- **databases/cockroach/** - CockroachDB Distributed SQL

## Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Valkey** | Redis community fork (BSD) | [valkey-io/valkey](https://github.com/valkey-io/valkey) |
| **PostgreSQL** | Advanced relational database | [postgres/postgres](https://github.com/postgres/postgres) |
| **MySQL** | Popular relational database | [mysql/mysql-server](https://github.com/mysql/mysql-server) |
| **MariaDB** | MySQL community fork | [MariaDB/server](https://github.com/MariaDB/server) |
| **MongoDB** | Document database | [mongodb/mongo](https://github.com/mongodb/mongo) |
| **Redis** | In-memory data store | [redis/redis](https://github.com/redis/redis) |
| **KeyDB** | Multi-threaded Redis fork | [Snapchat/KeyDB](https://github.com/Snapchat/KeyDB) |
| **CockroachDB** | Distributed SQL database | [cockroachdb/cockroach](https://github.com/cockroachdb/cockroach) |
| **TiDB** | Distributed MySQL-compatible DB | [pingcap/tidb](https://github.com/pingcap/tidb) |
| **CouchDB** | Document database with sync | [apache/couchdb](https://github.com/apache/couchdb) |
| **ClickHouse** | OLAP database | [ClickHouse/ClickHouse](https://github.com/ClickHouse/ClickHouse) |
| **TimescaleDB** | Time-series PostgreSQL | [timescale/timescaledb](https://github.com/timescale/timescaledb) |
| **InfluxDB** | Time-series database | [influxdata/influxdb](https://github.com/influxdata/influxdb) |

## Quick Start

```bash
cd databases/valkey/
cp .env.example .env
docker compose up -d
```

Connect to Valkey at `localhost:6379`.
