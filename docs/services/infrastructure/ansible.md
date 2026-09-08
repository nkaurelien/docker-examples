---
tags: ansible, automation, infrastructure
---

# Ansible Infrastructure Automation

This repository includes a complete Ansible deployment suite under `ansible/` designed to automate server preparation, Docker daemon configuration, SSL certificate management, Traefik reverse proxy deployment, and systemd service management.

---

## 🛠️ Included Ansible Roles

| Role | Description |
|---|---|
| **`common`** | Base system preparation (essential packages, prerequisites, users) |
| **`docker-daemon`** | Custom Docker daemon configuration (`daemon.json`, logs, subnets, registry) |
| **`ssl-certs`** | SSL/TLS certificate deployment and distribution |
| **`traefik`** | Traefik v3 Edge Router deployment with dynamic Docker discovery |
| **`systemd-service`** | Wraps Docker Compose stacks into systemd units for boot startup |
| **`deploy-cleanup`** | Automatic system and container prune maintenance |

---

## 🚀 Quick Commands via Makefile

You can run Ansible operations directly from the root workspace using the `make` commands:

```bash
# Test SSH connectivity to inventory hosts
make ansible-ping

# Verify playbook syntax
make ansible-syntax

# Display inventory structure and resolved variables
make ansible-inventory

# Execute the main playbook across all hosts
make ansible-deploy

# Install Galaxy roles and collections
make ansible-galaxy-install
```

---

## 🔒 Secret Management & Dynamic Lookups

All sensitive values (IP addresses, SSH passwords, API tokens) are stored in `.secrets/` and dynamically fetched at runtime:

```yaml
ansible_host: "{{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/ssh-contabo-server-ip') | trim }}"
ansible_user: "{{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/ssh-contabo-server-user-login') | trim }}"
ansible_password: "{{ lookup('file', '/Volumes/X9 Pro/Workspaces/nkaurelien/docker-examples/.secrets/ssh-contabo-server-password') | trim }}"
```

For full setup guidelines, consult the guide at `ansible/INSTALL.md`.
