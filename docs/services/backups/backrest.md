---
tags: backup, restic, backrest, rclone, orchestration
---

# Backrest — Web UI & Orchestrator for Restic

Backrest is an open-source, web-based user interface and task orchestrator designed specifically for Restic backup repositories.

![Backrest Overview](https://raw.githubusercontent.com/selfhst/icons/main/svg/restic.svg)

## Features

- **Web Dashboard**: Modern, clean browser interface to manage Restic repositories, snapshots, and restores.
- **Automated Scheduling**: Built-in cron scheduler for backup jobs, integrity checks, and repository prunes.
- **Snapshot Browser & File Restore**: Browse snapshot tree hierarchies and restore selected files or folders directly.
- **Hook Automation**: Execute pre- and post-backup shell commands for database dumps (`pg_dump`, `mysqldump`).
- **Multi-Backend Support**: Connect to S3, MinIO, SFTP, local paths, or Rclone remotes (40+ cloud providers).
- **Notifications**: Alerting support via Discord, Slack, Shoutrrr, Gotify, and Webhooks.

---

## Deployment Architecture

- **Service Container**: `garethgeorge/backrest:latest` (`backrest`)
- **Port**: `9898`
- **Reverse Proxy**: Traefik (`https://backrest.kamitbrains.fr`) with TLS (Let's Encrypt) and CrowdSec bouncer.
- **Volume Mounts**:
  - `backrest-config:/config` — Configuration database and credentials.
  - `backrest-cache:/cache` — Local Restic cache.
  - `/var/lib/docker/volumes:/userdata/volumes:ro` — Read-only host Docker volume access for backups.

---

## Access & Credentials

- **URL**: `https://backrest.kamitbrains.fr`
- **Default Username**: `admin`
- **Secrets Path**: `.secrets/backrest-admin-login` & `.secrets/backrest-admin-password`
