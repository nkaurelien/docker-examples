---
tags: backup, restic, autorestic, kopia, borg, rclone
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

## Best Practices for Docker Volume Backups

1. **Log Quotas & Rotation**: Ensure containers define `logging` limits (`max-size: 10m`, `max-file: 3`) to prevent unrotated logs from bloating backup archives.
2. **Resource Limits**: Restrict CPU and Memory allocations (`deploy.resources.limits`) on backup worker containers to maintain node stability.
3. **Database Pre-Hooks**: Always dump active databases (`pg_dump`, `mysqldump`) or freeze transactions prior to snapshot creation.
