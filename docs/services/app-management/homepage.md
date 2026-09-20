---
tags: app-management, dashboard, homepage, infrastructure
---

# Homepage Infrastructure Dashboard

[Homepage](https://gethomepage.dev/) is a modern, highly customizable application dashboard that centralizes shortcuts, status widgets, and docker container status across your infrastructure.

---

## Service Overview

| Attribute | Details |
| :--- | :--- |
| **Service Name** | `homepage` |
| **Primary URL** | `https://home.kamitbrains.fr` |
| **Alias URL** | `https://apps.kamitbrains.fr` |
| **Health Check** | `http://127.0.0.1:3000/` |
| **Docker Image** | `ghcr.io/gethomepage/homepage:latest` |
| **Reverse Proxy** | Traefik (`websecure` + Let's Encrypt TLS) |
| **Security** | CrowdSec ForwardAuth Bouncer |
| **Storage Directory** | `/opt/homepage/config` |

---

## Access & Features

- **Dual Domain Host Routing**: Access the portal from either `https://home.kamitbrains.fr` or `https://apps.kamitbrains.fr`.
- **Integrated Services**:
  - **Passbolt** (`https://passwords.kamitbrains.fr`)
  - **ChangeDetection** (`https://changedetection.kamitbrains.fr`)
  - **IT-Tools** (`https://tools.kamitbrains.fr`)
  - **Uptime Kuma** (`https://uptime.kamitbrains.fr`)
  - **Ntfy** (`https://ntfy.kamitbrains.fr`)
  - **Arcane** (`https://arcane.kamitbrains.fr`)
  - **Glances** (`https://glances.kamitbrains.fr`)
  - **TinyAuth** (`https://auth.kamitbrains.fr`)
  - **Traefik** (`https://traefik.kamitbrains.fr`)
- **System Metrics**: Real-time CPU, RAM, and disk utilization widgets.

---

## Architecture & Docker Compose Configuration

Managed via Ansible role in `ansible/roles/homepage/`.

```yaml
services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    restart: unless-stopped
    volumes:
      - ./config:/app/config
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.homepage.rule=Host(`home.kamitbrains.fr`) || Host(`apps.kamitbrains.fr`)"
      - "traefik.http.routers.homepage.entrypoints=websecure"
      - "traefik.http.routers.homepage.tls.certresolver=letsencrypt"
      - "traefik.http.routers.homepage.middlewares=crowdsec-bouncer@file"
      - "traefik.http.services.homepage.loadbalancer.server.port=3000"
```

---

## ⚖️ Le Panorama des Application Dashboards

Les **Application Dashboards** constituent le point d'entrée unique de tout Homelab ou infrastructure Cloud/K8s pour centraliser l'accès aux services, visualiser la santé du matériel et surveiller les métriques.

### 1. Comparatif des 3 Leaders : Homepage vs Homarr vs Heimdall

| Critère | **Homepage** (Choix actuel) | **Homarr** | **Heimdall** |
| :--- | :--- | :--- | :--- |
| **Philosophie** | **100% Déclaratif (GitOps)** : Configuré via fichiers YAML. Aucune base de données requise. | **Visuel & Modulaire** : Grille dynamique avec réorganisation par glisser-déposer (*drag-and-drop*). | **Lanceur d'applications épuré** : Solution classique basée sur PHP/Laravel, simple mur de tuiles. |
| **Configuration** | Fichiers YAML (`services.yaml`, `widgets.yaml`) ou ConfigMaps Kubernetes. | Interface Web interactive dans le navigateur (+ base SQLite interne). | Interface Web simplifiée (édition directe des boutons/icônes). |
| **Intégrations & Widgets** | Très riches : Kubernetes natif (CPU/RAM/Pods), Docker, Traefik, Uptime Kuma, Glances, etc. | Riches : Docker, Torrent, Dashboards média, métriques météo/système. | Basiques : Badges d'état pour certains services compatibles (ex: Pi-hole). |
| **Performances & Empreinte** | Ultra-léger (~50 Mo RAM, Next.js optimisé). | Modéré (~150-250 Mo RAM, stack Node/Web). | Léger (~60 Mo RAM, stack Nginx/PHP). |
| **Idéal pour** | Homelabs orientés **DevOps, Kubernetes et GitOps** (versionnable dans Git). | Utilisateurs préférant **tout gérer à la souris** sans toucher au YAML. | Besoins de **favoris partagés simples** sans complexité technique. |

### 2. Autres options notables

- **Dashy** : Extrêmement personnalisable (des dizaines de thèmes, widgets dynamiques, vérification de statut intégrée), configuration en YAML. Idéal si vous aimez tweaker et peaufiner l'UI dans tous les moindres détails.
- **Glance** : Plus orienté « *startpage* » moderne et ultra-légère avec flux RSS, météo et quelques widgets systèmes. Très rapide et épuré, moins orienté « dashboard d'administration complet ».
- **Homer / Flame / SUI** : Pages de liens statiques et minimalistes. Parfaites pour un annuaire d'URLs ultra-léger et rapide sans dépendances lourdes ni widgets complexes.


