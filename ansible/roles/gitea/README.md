# Ansible Role: Gitea Self-Hosted Git Platform

Role Ansible pour le déploiement et la gestion d'une instance **Gitea** (Git & CI/CD Actions), avec base de données **PostgreSQL 16**, derrière le reverse proxy **Traefik v3**.

---

## 📋 Fonctionnalités

- Déploiement automatique de Gitea (`v1.22.6`).
- Base de données PostgreSQL 16 dédiée.
- Intégration Traefik v3 (`docker-compose.override.yml`) avec HTTPS et redirection SSL.
- Configuration du service systemd (`gitea.service`).
- Création automatique de l'utilisateur admin via CLI Gitea.
- Isolation des secrets non versionnés (`.secrets/gitea-admin-password`, `.secrets/gitea-db-password`, `.secrets/gitea-secret-key`).

---

## ⚙️ Variables du Rôle (`defaults/main.yml`)

```yaml
gitea_version: "1.22.6"
gitea_domain: "kamitbrains-minipc-k1.lab"
gitea_hostname: "gitea.{{ gitea_domain }}"
gitea_deploy_dir: "/opt/gitea"
```

---

## 🚀 Utilisation

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags gitea --limit homelab
```
