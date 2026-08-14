# Media & Storage

Object storage, file sharing, and media management solutions.

## Object Storage

S3-compatible storage and cloud storage solutions.

### Existing Projects

- **object-storage/minio-s3/** - S3-compatible object storage
- **object-storage/using-s3fs-volume/** - S3FS volume examples

### Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **MinIO** | S3-compatible object storage | [minio/minio](https://github.com/minio/minio) |
| **SeaweedFS** | Distributed file system | [seaweedfs/seaweedfs](https://github.com/seaweedfs/seaweedfs) |
| **Ceph** | Distributed storage system | [ceph/ceph](https://github.com/ceph/ceph) |
| **GlusterFS** | Scalable network filesystem | [gluster/glusterfs](https://github.com/gluster/glusterfs) |
| **Garage** | S3-compatible distributed storage | [deuxfleurs-org/garage](https://github.com/deuxfleurs-org/garage) |

---

## File Sharing

File sync, sharing, and collaboration platforms.

### Existing Projects

- **file-sharing/** - File sharing solutions

### Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Nextcloud** | File sync and share | [nextcloud/server](https://github.com/nextcloud/server) |
| **ownCloud** | File sync and share | [owncloud/core](https://github.com/owncloud/core) |
| **Seafile** | File sync and share | [haiwen/seafile](https://github.com/haiwen/seafile) |
| **Syncthing** | Continuous file sync | [syncthing/syncthing](https://github.com/syncthing/syncthing) |
| **FileBrowser** | Web file manager | [filebrowser/filebrowser](https://github.com/filebrowser/filebrowser) |
| **Send** | Encrypted file sharing | [timvisee/send](https://github.com/timvisee/send) |
| **Zipline** | File sharing platform | [diced/zipline](https://github.com/diced/zipline) |

---

## Static Files

Static file servers and media streaming.

### Existing Projects

- **static-files/statics-files-server/** - Static file serving

### Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Caddy** | Web server with file server | [caddyserver/caddy](https://github.com/caddyserver/caddy) |
| **Nginx** | High-performance web server | [nginx/nginx](https://github.com/nginx/nginx) |
| **Photoprism** | AI-powered photo app | [photoprism/photoprism](https://github.com/photoprism/photoprism) |
| **Immich** | Photo and video backup | [immich-app/immich](https://github.com/immich-app/immich) |
| **LibrePhotos** | Photo management | [LibrePhotos/librephotos](https://github.com/LibrePhotos/librephotos) |
| **Jellyfin** | Media streaming server | [jellyfin/jellyfin](https://github.com/jellyfin/jellyfin) |
| **Navidrome** | Music streaming server | [navidrome/navidrome](https://github.com/navidrome/navidrome) |

---

## Quick Start

```bash
# MinIO
cd object-storage/minio-s3/
docker compose up -d
```

Access MinIO console at `http://minio.apps.local`.
