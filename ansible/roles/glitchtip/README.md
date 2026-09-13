# GlitchTip Ansible Role

Ansible role to deploy [GlitchTip](https://glitchtip.com/) (open-source, Sentry SDK compatible error tracking, crash reporting, and APM performance monitoring) on Docker with PostgreSQL 17, Valkey 9, and Traefik reverse proxying.

---

## 📋 Role Overview

- **Service Name**: `glitchtip`
- **Container Stack**:
  - `glitchtip`: GlitchTip Web Granian & Celery worker (`glitchtip/glitchtip:6`)
  - `glitchtip-db`: PostgreSQL 17 database (`postgres:17`)
  - `glitchtip-valkey`: Valkey 9 in-memory cache & task queue (`valkey/valkey:9`)
  - `glitchtip-init`: Superuser creation task (`createsuperuser`)
- **Reverse Proxy**: Traefik (`websecure` + Let's Encrypt TLS)
- **Public Domain**: `https://glitchtip.kamitbrains.fr` (or `https://glitchtip.{{ traefik_domain }}`)

---

## ⚙️ Role Variables (`defaults/main.yml`)

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `glitchtip_version` | `"6"` | GlitchTip Docker image tag |
| `glitchtip_image` | `"glitchtip/glitchtip:6"` | Full Docker image reference |
| `glitchtip_postgres_image` | `"postgres:17"` | PostgreSQL image reference |
| `glitchtip_valkey_image` | `"valkey/valkey:9"` | Valkey image reference |
| `glitchtip_domain` | `"kamitbrains.fr"` | Primary base domain |
| `glitchtip_hostname` | `"glitchtip.{{ traefik_domain \| default(glitchtip_domain) }}"` | Public FQDN |
| `glitchtip_compose_dir` | `"/opt/glitchtip"` | Host directory for Docker Compose |
| `glitchtip_container_port` | `8000` | GlitchTip web server port |
| `glitchtip_db_name` | `"glitchtip"` | PostgreSQL database name |
| `glitchtip_db_user` | `"glitchtip"` | PostgreSQL database username |
| `glitchtip_admin_email` | `"admin@kamitbrains.fr"` | Initial Django admin email |

---

## 🔐 Secret Files

The role automatically loads secrets from the local `.secrets/` directory:
- `.secrets/glitchtip-admin-password`: Admin user password
- `.secrets/glitchtip-db-password`: PostgreSQL database password
- `.secrets/glitchtip-secret-key`: Django application secret key

---

## 🚀 Execution Commands

Deploy GlitchTip via Ansible:

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags glitchtip
```

Deploy GlitchTip together with Homepage:

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags "glitchtip,homepage"
```

---

## 🧪 Health & Logs Inspection

Check running containers:
```bash
docker compose -f /opt/glitchtip/docker-compose.yml ps
```

View application logs:
```bash
docker logs glitchtip -f
```
