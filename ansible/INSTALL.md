---
tags: ansible, automation, cloudflare, installation, utilisation
---

# Guide d'Installation et d'Utilisation - Ansible & Cloudflare Automation

Ce dossier contient la suite de déploiement Ansible et les outils d'automatisation Cloudflare pour nos infrastructures (dont le serveur Contabo FR).

---

## 📋 Prérequis

1. **Ansible & Collections** :
   Assurez-vous d'avoir `ansible` et `ansible-galaxy` installés sur votre machine hôte.
   Pour installer la collection requise (`community.docker`) ainsi que les rôles Galaxy :
   ```bash
   make ansible-galaxy-install
   # ou directement :
   ansible-galaxy collection install community.docker
   ansible-galaxy role install -r requirements.yml
   ```

2. **Fichiers de Secrets (`.secrets/`)** :
   Les informations sensibles sont stockées dans le dossier `.secrets/` à la racine du projet et lues dynamiquement par Ansible et par le SDK Cloudflare :
   * `.secrets/ssh-contabo-server-ip` : Adresse IP du serveur.
   * `.secrets/ssh-contabo-server-user-login` : Nom d'utilisateur SSH (ex: `nkaurelien`).
   * `.secrets/ssh-contabo-server-password` : Mot de passe SSH.
   * `.secrets/cloudflare-account-id` : ID du compte Cloudflare.
   * `.secrets/cloudflare-api-key` : Jeton d'API Bearer Cloudflare.

---

## 📁 Structure du Projet

```text
ansible/
├── ansible.cfg            # Configuration Ansible (roles_path, callbacks, escalade sudo)
├── ansible.mk             # Module Makefile incluant les cibles ansible-*
├── group_vars/
│   ├── all.yml            # Variables globales pour tous les hôtes
│   └── webservers_fr.yml  # Variables spécifiques et lookups du groupe FR
├── inventory.yml          # Inventaire dynamique des hôtes
├── requirements.yml       # Dépendances Rôles Galaxy et Collections
├── site.yml               # Playbook principal orchestrant les rôles
└── roles/
    ├── common/            # Configuration de base du système
    ├── deploy-cleanup/    # Nettoyage automatique Docker & système
    ├── docker-daemon/     # Configuration avancée du démon Docker
    ├── ssl-certs/         # Déploiement et distribution des certificats SSL/TLS
    ├── systemd-service/   # Gestion des stacks via services systemd
    └── traefik/           # Reverse Proxy Traefik v3 avec découverte Docker

scripts/
└── cloudflare_dns.py      # CLI d'administration DNS Cloudflare via SDK officiel
```

---

## 🚀 Utilisation via `make` et `just`

Vous pouvez utiliser les commandes `make` ou `just` définies à la racine du projet pour orchestrer les déploiements :

### Déploiement global (Tous les rôles)
```bash
# Via make
make ansible-deploy

# Via just
just ansible-deploy-homelab
```

### Déploiement ciblé rapide (Tags)
```bash
# Déployer uniquement un service spécifique (ex. Homepage)
make ansible-deploy TAGS="homepage"
just ansible-deploy-homelab TAGS="homepage"

# Déployer plusieurs services ciblés
make ansible-deploy TAGS="open-webui,jenkins"

# Déployer toutes les applications en sautant la préparation système lente (apt update)
make ansible-deploy TAGS="apps"
make ansible-deploy SKIP_TAGS="common"
```

---

## 🎯 Commandes ciblées Ansible directes

Vous pouvez également passer par la CLI `ansible-playbook` directement dans le dossier `ansible/` :

```bash
cd ansible

# Déployer uniquement Traefik
ansible-playbook site.yml -l homelab --tags traefik

# Déployer la préparation système et Docker
ansible-playbook site.yml -l homelab --tags "common,docker"

# Exécuter les tâches de nettoyage
ansible-playbook site.yml -l homelab --tags cleanup
```

---

## 🏷️ Tagger des conteneurs pour Traefik

Traefik est configuré pour écouter le socket Docker et le réseau `traefik-public`. Pour exposer un conteneur via Traefik, ajoutez les labels suivants dans votre `docker-compose.yml` :

```yaml
services:
  mon-service:
    image: nginx:alpine
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.mon-service.rule=Host(`mon-service.kamitbrains.fr`)"
      - "traefik.http.routers.mon-service.entrypoints=web"
      - "traefik.http.services.mon-service.loadbalancer.server.port=80"

networks:
  traefik-public:
    external: true
```
