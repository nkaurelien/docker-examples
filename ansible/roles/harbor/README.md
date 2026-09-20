# Ansible Role: Harbor OCI Container & Artifact Registry

Role Ansible pour le déploiement et la gestion d'un registre d'artefacts d'entreprise **Harbor v2.11+** avec le scanner de vulnérabilités **Trivy** intégré, derrière le reverse proxy **Traefik**.

---

## 📋 Fonctionnalités

- Déploiement automatique de l'installateur Harbor online (`v2.11.1`).
- Génération dynamique de `harbor.yml` avec support du scanner **Trivy**.
- Intégration Traefik v3 (`docker-compose.override.yml`) avec routage multi-domaines (HTTP 80 -> HTTPS 443).
- Persistance et sécurité des secrets non versionnés (`.secrets/harbor-admin-password`, `.secrets/harbor-db-password`, `.secrets/harbor-secret-key`).
- Intégration au démarrage système via `systemd` (`harbor.service`).

---

## ⚙️ Variables du Rôle (`defaults/main.yml`)

```yaml
harbor_version: "v2.11.1"
harbor_domain: "kamitbrains-minipc-k1.lab"
harbor_hostname: "harbor.{{ harbor_domain }}"
harbor_deploy_dir: "/opt/harbor"
harbor_data_dir: "/opt/harbor/data"

# Scanner Trivy
harbor_trivy_enabled: true
```

---

## 🔒 Gestion des Secrets (.secrets/)

Les secrets suivants sont lus depuis le répertoire `.secrets/` (ignoré par Git) :

- `.secrets/harbor-admin-login` (défaut : `admin`)
- `.secrets/harbor-admin-password` (Mot de passe admin)
- `.secrets/harbor-db-password` (Mot de passe PostgreSQL)
- `.secrets/harbor-secret-key` (Clef de chiffrement interne)

---

## 🚀 Utilisation

```bash
# Déploiement complet de Harbor sur la machine Homelab K1 Mini
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags harbor --limit homelab
```

---

## 🛠️ Dépannage & Maintenance

### Réinitialisation du Mot de Passe Administrateur

Si le mot de passe admin doit être réinitialisé en base de données :

```bash
# Effacer l'ancienne empreinte dans la base PostgreSQL Harbor
ansible homelab -i ansible/inventory.yml -m shell -a "docker exec harbor-db psql -U postgres -d registry -c \"UPDATE harbor_user SET salt='', password='', password_version='' WHERE user_id = 1;\" && docker exec redis redis-cli flushall && cd /opt/harbor && docker compose restart core" --become
```
