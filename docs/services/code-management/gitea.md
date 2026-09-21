---
tags: code-management, git, gitea, devops, ci-cd
---

# Gitea - Self-Hosted Git Platform & Actions CI/CD

Gitea is a lightweight, self-hosted, all-in-one software development platform featuring Git repository management, Code Review (Pull Requests), Issue Tracking, Built-in Package Registries, and Gitea Actions (CI/CD runner).

## Architecture & Homelab Setup

- **Host**: `192.168.0.205` (`kamitbrains_homelab`)
- **Web Interface URL**: `https://gitea.kamitbrains-minipc-k1.lab` (also `gitea.kamitbrains.local`, `gitea.kamitbrains.fr`)
- **HTTP Internal Port**: `3000`
- **SSH Port**: `2223` (mapped to container port `22` to avoid collision with Forgejo on `2222`)
- **Database Engine**: PostgreSQL 16 (`postgres:16-alpine`)
- **Data Mount Directory**: `/opt/gitea/data` (mounted to `/data` in container with UID/GID 1000)

## Quick Start (Docker Compose)

```bash
cd compose/08-code-management/gitea
docker compose up -d
```

## Ansible Deployment

The automated role is located at `ansible/roles/gitea/` and configured in `ansible/site.yml`:

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags gitea
```

### Role Files
- `ansible/roles/gitea/tasks/main.yml`: Directory creation (UID 1000 permissions), configuration templates deployment, Docker Compose stack startup, and systemd service registration.
- `ansible/roles/gitea/templates/app.ini.j2`: Production configuration with `WORK_PATH = /data/gitea` and PostgreSQL parameters.
- `ansible/roles/gitea/templates/docker-compose.override.yml.j2`: Traefik v3 HTTP and HTTPS routing labels.

## Kubernetes K3s & Helm Setup

Official Gitea documentation recommendations (`https://docs.gitea.com/installation/install-on-kubernetes/`) are codified under `helm/` and `kubernetes/`:

### Helm Values Configuration
File: `helm/values/gitea/values.yaml`

```yaml
ingress:
  enabled: true
  className: traefik
  hosts:
    - host: gitea.kamitbrains-minipc-k1.lab
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: gitea-ingress-tls
      hosts:
        - gitea.kamitbrains-minipc-k1.lab

gitea:
  admin:
    username: "gitea_admin"
    email: "admin@kamitbrains-minipc-k1.lab"
  config:
    server:
      DOMAIN: gitea.kamitbrains-minipc-k1.lab
      ROOT_URL: https://gitea.kamitbrains-minipc-k1.lab/
      SSH_PORT: 2223
```

### Kubernetes Native Manifests
File: `kubernetes/apps/code-management/gitea.yaml`

```bash
kubectl apply -f kubernetes/apps/code-management/gitea.yaml
```

## CLI Administration

To manage Gitea users via CLI inside the running Docker container:

```bash
# List existing users
docker exec -u 1000 gitea gitea admin user list

# Create an administrator user
docker exec -u 1000 gitea gitea admin user create --admin --username gitea_admin --password "<PASSWORD>" --email "admin@kamitbrains-minipc-k1.lab" --must-change-password=false
```

## Secret Isolation

Administrative credentials and database keys are managed out-of-tree in `.secrets/` (gitignored):
- `.secrets/gitea-admin-login`
- `.secrets/gitea-admin-password`
- `.secrets/gitea-db-password`
- `.secrets/gitea-secret-key`
- `.secrets/gitea.md`

## References & Official Docs

- [Gitea Official Documentation](https://docs.gitea.com/)
- [Installation with Docker](https://docs.gitea.com/installation/install-with-docker/)
- [Installation on Kubernetes](https://docs.gitea.com/installation/install-on-kubernetes/)
