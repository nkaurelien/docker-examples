# Valkey In-Memory Data Store Compose Stack

[Valkey](https://valkey.io/) is an open-source, high-performance in-memory data store (BSD-licensed community fork of Redis supported by the Linux Foundation).

---

## Quick Start

```bash
cp .env.example .env
docker compose up -d
```

## Service Details

| Attribute | Value |
| :--- | :--- |
| **Image** | `valkey/valkey:9-alpine` |
| **Port** | `6379` |
| **Container Name** | `asone-valkey` |
| **Data Persistence** | Enabled (`--appendonly yes`) |
| **Health Check** | `valkey-cli -a ${VALKEY_PASSWORD} ping` |

## Test Connection

```bash
docker exec -it asone-valkey valkey-cli -a valkey123 ping
# Expected output: PONG
```
