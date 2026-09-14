---
tags: backup, restic, autorestic, kopia, borg, rclone, databasement, scripts
---

# Backup & Recovery Solutions

Standardized backup and snapshot solutions for self-hosted Docker volumes and Linux servers.

## Recommended Backup Tools

### 1. Restic, Autorestic & GUI Tools (Recommended)
- **Description**: The modern, fast, lightweight, end-to-end encrypted, and deduplicated backup tool.
- **Rclone Integration**: Restic natively supports **Rclone** as a backend (`rclone:remote:path`). This enables backing up Docker volumes to over 40+ storage providers (Google Drive, OneDrive, Dropbox, Mega, Backblaze B2, S3, MinIO, SFTP) with client-side encryption.
- **Autorestic**: A CLI wrapper around Restic that uses simple YAML configuration files to schedule and automate volume backups effortlessly.
- **Backrest**: Web-based UI and orchestrator for Restic deployed via Docker, providing a web dashboard for cron schedules, snapshot browsing, and notifications.
- **Restic Browser (`emuell/restic-browser`)**: Cross-platform desktop GUI (Tauri/Rust) to browse snapshots, inspect files, and restore items from Restic repositories locally without using CLI commands.

### 2. Kopia
- **Description**: Fast and secure backup tool featuring a rich Web GUI for snapshot management, browsing file versions, and quick restores.
- **Use Case**: Excellent for administrators who prefer a graphical web interface to manage backups and policy retentions.

### 3. BorgBackup & Borgmatic
- **Description**: De-duplicating, authenticated, and encrypted backup program with high compression efficiency.
- **Borgmatic**: Declarative configuration layer for BorgBackup, making it ideal for Linux system backups and automated PostgreSQL/MariaDB dump hooks.

### 4. Databasement
- **Description**: Self-hosted database backup manager with a Web UI. Supports MySQL, PostgreSQL, MariaDB, MSSQL, MongoDB, SQLite, and Redis with SSH tunnel support.
- **Use Case**: Ideal for automated database backups, cross-server database restores (prod → staging), and multi-tenant workspace management.

---

## Comparative Matrix

| Tool | Encryption | Deduplication | Web UI | Primary Backend Support |
| :--- | :---: | :---: | :---: | :--- |
| **Restic / Autorestic** | AES-256 | Chunk-level | Backrest / Restic Browser | S3, MinIO, SFTP, REST, Rclone (40+ providers) |
| **Databasement** | AES-256 / gzip / zstd | N/A (DB Dumps) | Native Web GUI | S3, SFTP, SMB, Local Storage |
| **Kopia** | AES-256 / ChaCha20 | Chunk-level | Native Web GUI | S3, SFTP, WebDAV, Local, GCP, Azure |
| **Borg / Borgmatic** | AES-256 / HMAC | Chunk-level | BorgWarehouse / Vorta | SSH / SFTP, Local Host |

---

## Custom In-House Backup Pattern (Outil Maison avec Restic)

For environments requiring full auditability, minimal external dependencies, and complete control over database dumps and snapshot lifecycles, an **In-House Scripting Pattern with Restic** is recommended.

```
┌─────────────────────────────────────────────────────────┐
│                    Database Dump Stage                  │
│  mysqldump / mariadb-dump │ pg_dump │ sqlite3 .backup   │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                      Restic Engine                      │
│     Client-side AES-256 Encryption & Deduplication      │
└────────────────────────────┬────────────────────────────┘
                             │
            ┌────────────────┼────────────────┐
            ▼                ▼                ▼
     ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
     │ S3 / MinIO  │  │ SFTP / NAS  │  │ Local Disk  │
     └─────────────┘  └─────────────┘  └─────────────┘
```

### Key Advantages
- **Client-Side Encryption**: Zero-knowledge encryption (AES-256 + Poly1305) before data leaves the server.
- **Chunk-Level Deduplication**: Reduces storage costs by transferring only modified database blocks.
- **Flexible Retention**: Declarative pruning strategies (`restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --prune`).
- **Universal Storage Targets**: Native support for S3, MinIO, SFTP, SSH, NAS, and local disks.
- **Automated Verification**: Easily verify repository integrity (`restic check`) and run test restores in CI/CD pipelines.
- **Seamless Scheduling**: Easily triggers via cron, systemd timers, Docker init containers, or Kubernetes CronJobs.

### Reference Bash Implementation Pattern

```bash
#!/usr/bin/env bash
set -euo pipefail

# Configuration
ENGINE="${1:-mysql}"
DATABASE="${2:-app_db}"
OUTPUT="/tmp/backups/${DATABASE}_$(date +%Y%m%d_%H%M%S)"
RESTIC_REPOSITORY="${RESTIC_REPOSITORY:-s3:https://s3.amazonaws.com/my-backup-bucket}"

mkdir -p /tmp/backups

# 1. Execute DB Dump
case "$ENGINE" in
  mysql|mariadb)
    mysqldump --single-transaction --quick "$DATABASE" > "${OUTPUT}.sql"
    DUMP_FILE="${OUTPUT}.sql"
    ;;
  postgresql)
    pg_dump --format=custom "$DATABASE" > "${OUTPUT}.dump"
    DUMP_FILE="${OUTPUT}.dump"
    ;;
  sqlite)
    sqlite3 "$DATABASE" ".backup '${OUTPUT}.sqlite'"
    DUMP_FILE="${OUTPUT}.sqlite"
    ;;
  *)
    echo "Unsupported database engine: $ENGINE"
    exit 1
    ;;
esac

# 2. Ingest into Restic Repository
restic -r "$RESTIC_REPOSITORY" backup "$DUMP_FILE" --tag "db,${ENGINE},${DATABASE}"

# 3. Apply Retention Policy & Cleanup Staging File
restic -r "$RESTIC_REPOSITORY" forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --prune
rm -f "$DUMP_FILE"
```

---

## Best Practices for Docker Volume Backups

1. **Log Quotas & Rotation**: Ensure containers define `logging` limits (`max-size: 10m`, `max-file: 3`) to prevent unrotated logs from bloating backup archives.
2. **Resource Limits**: Restrict CPU and Memory allocations (`deploy.resources.limits`) on backup worker containers to maintain node stability.
3. **Database Pre-Hooks**: Always dump active databases (`pg_dump`, `mysqldump`) or freeze transactions prior to snapshot creation.
