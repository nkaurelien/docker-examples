# Paperless-ngx Document Management Credentials & Documentation

- **Service**: Paperless-ngx Open Source Document Management System & OCR
- **URL**: https://paperless.kamitbrains.fr (or https://docs.kamitbrains.fr)
- **Database Engine**: PostgreSQL 16 (`postgres:16-alpine`)
- **Broker**: Valkey 8 (`valkey/valkey:8-alpine`)
- **OCR Engine**: Tesseract (fra+eng)
- **Admin Login File**: `.secrets/paperless-admin-login`
- **Admin Password File**: `.secrets/paperless-admin-password`
- **DB Password File**: `.secrets/paperless-db-password`
- **Secret Key File**: `.secrets/paperless-secret-key`
- **Protection**: Traefik TLS + CrowdSec Bouncer + Native Paperless Auth
