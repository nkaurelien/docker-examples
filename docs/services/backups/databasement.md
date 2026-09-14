---
tags: backup, database, databasement, mysql, postgresql, mongodb, redis
---

# Databasement — Multi-Database Backup Manager & Web UI

Databasement is an open-source, self-hosted database backup management application featuring a clean Web UI.

![Databasement Overview](https://raw.githubusercontent.com/selfhst/icons/main/svg/postgresql.svg)

## Features

- **Multi-Database Support**: Backup and restore MySQL, MariaDB, PostgreSQL, Microsoft SQL Server, MongoDB, SQLite, Firebird, and Redis/Valkey.
- **SSH Tunnels**: Connect to private database instances behind bastion/jump servers.
- **Automated Scheduling**: Cron-like scheduling with time-based or GFS retention policies.
- **Encrypted Destinations**: Store backups to S3, SFTP, SMB, or local storage with gzip, zstd, or AES-256 encryption.
- **Cross-Server Restores**: Replay snapshots from production to staging servers automatically.
- **Notifications**: Real-time alerts via Email, Slack, Discord, Telegram, Pushover, Gotify, or Webhooks.

---

## Deployment Architecture

- **Service Container**: `davidcrty/databasement:latest` (`databasement`)
- **Port**: `2226`
- **Reverse Proxy**: Traefik (`https://databasement.kamitbrains.fr`) with TLS (Let's Encrypt) and CrowdSec bouncer.
- **Volume Mounts**:
  - `databasement-data:/data` — SQLite database and job storage.

---

## Access & Credentials

- **URL**: `https://databasement.kamitbrains.fr`
- **Secrets Path**: `.secrets/databasement-admin-login` & `.secrets/databasement-admin-password`
