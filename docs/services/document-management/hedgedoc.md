---
tags: collaboration, collaborative, document-management, editor, hedgedoc, markdown
---

# HedgeDoc — Collaborative Real-Time Markdown Editor

**HedgeDoc** (anciennement HackMD CE) est un éditeur de texte collaboratif en temps réel axé sur la syntaxe Markdown. Il permet d'écrire, de partager et de présenter des notes en direct.

---

## 🚀 Fonctionnalités principales

- **Édition collaborative en temps réel** : Travail simultané à plusieurs sur les mêmes notes Markdown.
- **En-têtes Front Matter YAML** : Prise en charge des métadonnées (`tags`, `title`, `description`, `lang`, `breaks`, `robots`, `type`, `dir`).
- **Mode Présentation (Slide Mode)** : Conversion automatique des notes en présentations interactives (Reveal.js via `type: slide`).
- **Intégration Traefik & SSO** : Sécurisé par Traefik, TinyAuth SSO et bouncer CrowdSec.
- **Stockage léger** : Base SQLite (ou PostgreSQL/MySQL) et volumes locaux pour les téléversements.

---

## 🏷️ Options YAML Metadata HedgeDoc

HedgeDoc supporte le bloc Front Matter YAML au début des fichiers `.md` pour personnaliser l'affichage, le comportement et le référencement :

```yaml
---
title: Titre de la note
description: Description courte pour le SEO et le partage
tags: devops, security, wireguard
lang: fr
dir: ltr
breaks: false
robots: noindex, nofollow
type: slide
---
```

| Option | Exemple | Description |
|---|---|---|
| `tags` | `tags: devops, security, wireguard` | Mots-clés pour classer et filtrer les notes dans HedgeDoc |
| `title` | `title: Mon titre personnalisé` | Définit le titre du document (prioritaire sur le premier `# H1`) |
| `description` | `description: Résumé du document...` | Méta-description HTML pour le mode publication / partage |
| `lang` | `lang: fr` (ou `en`) | Code langue ISO pour la typographie du navigateur |
| `breaks` | `breaks: false` | Active (`true`) ou désactive (`false`) les sauts de ligne automatiques |
| `robots` | `robots: noindex, nofollow` | Contrôle d'indexation par les moteurs de recherche |
| `type` | `type: slide` | Active le mode présentation de diapositives |
| `dir` | `dir: ltr` | Sens de lecture (`ltr` ou `rtl`) |

---

## 🌐 URLs & Accès

- **URL Principale** : [https://pad.kamitbrains.fr](https://pad.kamitbrains.fr)
- **Authentification** : Protégé par TinyAuth / SSO

---

## 🛠️ Stack Docker Compose

```yaml
services:
  hedgedoc:
    image: quay.io/hedgedoc/hedgedoc:latest
    container_name: hedgedoc
    restart: unless-stopped
    environment:
      - CMD_DOMAIN=pad.kamitbrains.fr
      - CMD_URL_ADAPTER=https
      - CMD_PROTOCOL_USERRAG=true
      - CMD_DB_URL=sqlite:///hedgedoc/data/hedgedoc.sqlite
      - CMD_ALLOW_FREEURL=true
      - CMD_ALLOW_ANONYMOUS=true
      - CMD_ALLOW_EMAIL_REGISTER=true
    volumes:
      - ./uploads:/hedgedoc/public/uploads
      - ./data:/hedgedoc/data
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.hedgedoc.rule=Host(`pad.kamitbrains.fr`)"
      - "traefik.http.routers.hedgedoc.entrypoints=websecure"
      - "traefik.http.routers.hedgedoc.tls.certresolver=letsencrypt"
      - "traefik.http.routers.hedgedoc.middlewares=crowdsec-bouncer@file,tinyauth-auth@docker"
      - "traefik.http.services.hedgedoc.loadbalancer.server.port=3000"

networks:
  traefik-public:
    external: true
```
