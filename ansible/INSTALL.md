# Guide d'Installation et d'Utilisation - Ansible Workspace

Ce dossier contient la suite de déploiement et de gestion d'infrastructure Ansible pour nos serveurs (dont le serveur Contabo FR).

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
   Les informations sensibles (IP, utilisateur, mot de passe) sont stockées dans le dossier `.secrets/` à la racine du projet et lues dynamiquement par Ansible :
   * `.secrets/ssh-contabo-server-ip` : Adresse IP du serveur.
   * `.secrets/ssh-contabo-server-user-login` : Nom d'utilisateur SSH (ex: `nkaurelien`).
   * `.secrets/ssh-contabo-server-password` : Mot de passe SSH.

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
```

---

## 🚀 Utilisation via `make`

Vous pouvez utiliser les commandes `make` définies à la racine du projet :

```bash
# Tester la connectivité SSH avec tous les serveurs de l'inventaire
make ansible-ping

# Vérifier la syntaxe du playbook site.yml
make ansible-syntax

# Afficher la structure et les variables de l'inventaire
make ansible-inventory

# Exécuter le playbook principal sur l'ensemble de l'infrastructure
make ansible-deploy
```

---

## 🎯 Commandes ciblées (Tags)

Si vous souhaitez exécuter un rôle spécifique (ex. Traefik) :

```bash
cd ansible

# Déployer uniquement Traefik
ansible-playbook site.yml --tags traefik

# Déployer la préparation système et Docker
ansible-playbook site.yml --tags "common,docker"

# Exécuter les tâches de nettoyage
ansible-playbook site.yml --tags cleanup
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
      - "traefik.http.routers.mon-service.rule=Host(`mon-service.apps.local`)"
      - "traefik.http.routers.mon-service.entrypoints=web"
      - "traefik.http.services.mon-service.loadbalancer.server.port=80"

networks:
  traefik-public:
    external: true
```
