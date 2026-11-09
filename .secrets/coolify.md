# Coolify PaaS Stack Credentials & Documentation

- **Service**: Coolify Self-Hostable PaaS & App Store
- **URL**: https://coolify.example.com
- **Database Engine**: PostgreSQL 15 (`postgres:15-alpine`)
- **Cache Engine**: Redis 7 (`redis:7-alpine`)
- **Root Admin Email File**: `.secrets/coolify-admin-email`
- **Root Admin Password File**: `.secrets/coolify-admin-password`
- **DB Password File**: `.secrets/coolify-db-password`
- **App Key File**: `.secrets/coolify-app-key`
- **Protection**: Traefik TLS + CrowdSec Bouncer + Native Coolify Auth
