---
tags: collaboration, collaborative, document-management, editor, hedgedoc, markdown
---

# HedgeDoc — Collaborative Real-Time Markdown Editor

**HedgeDoc** (anciennement HackMD CE) est un éditeur de texte collaboratif en temps réel axé sur la syntaxe Markdown. Il permet d'écrire, de partager et de présenter des notes en direct.

---

## 🚀 Fonctionnalités principales

- **Édition collaborative en temps réel** : Travail simultané à plusieurs sur les mêmes notes Markdown.
- **En-têtes Front Matter YAML** : Prise en charge des métadonnées (ex: `tags: features, cool, updated`).
- **Mode Présentation (Slide Mode)** : Conversion automatique des notes en présentations interactives (Reveal.js).
- **Intégration Traefik & SSO** : Sécurisé par Traefik, TinyAuth SSO et bouncer CrowdSec.
- **Stockage léger** : Base SQLite (ou PostgreSQL/MySQL) et volumes locaux pour les téléversements.

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
