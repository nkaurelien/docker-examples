---
tags: dev-tools, ocr, pdf, pdf-suite, stirling-pdf
---

# Stirling-PDF — Full-Featured Server-Side PDF Suite & OCR

**Stirling-PDF** est une suite logicielle serveur complète, open-source et auto-hébergée pour la manipulation de fichiers PDF (fusion, découpage, OCR Tesseract, conversion Office/Images ➔ PDF, filigranes, chiffrement/déchiffrement, signature).

---

## 🚀 Fonctionnalités principales

- **Opérations PDF serveur** : Fusion, scission, extraction de pages, rotation, filigranes, numérotation, chiffrement OpenSSL.
- **Reconnaissance optique de caractères (OCR)** : Moteur Tesseract intégré (Support multilingue FR/EN).
- **Conversions multi-formats** : PDF vers Images (PNG/JPG), HTML, Markdown, Word, PDF/A.
- **Sécurité SSO** : Protégé par **TinyAuth SSO** (`tinyauth-auth@docker`) et **CrowdSec Bouncer**.

---

## 🌐 URLs & Accès

- **URL Principale** : [https://stirling.kamitbrains.fr](https://stirling.kamitbrains.fr)
- **Aliases de domaine** :
  - [https://stirling-pdf.kamitbrains.fr](https://stirling-pdf.kamitbrains.fr)
  - [https://pdf2.kamitbrains.fr](https://pdf2.kamitbrains.fr)
- **Authentification** : TinyAuth SSO (`admin@kamitbrains.fr` / `admin`)

---

## 🛠️ Configuration Docker & Ansible

Le rôle Ansible se trouve dans `ansible/roles/stirling-pdf`.

### Service `docker-compose.yml`

```yaml
services:
  stirling-pdf:
    image: stirlingtools/stirling-pdf:latest
    container_name: stirling-pdf
    restart: unless-stopped
    environment:
      - DOCKER_ENABLE_SECURITY=false
      - UI_APPNAME=Stirling-PDF
      - LANGS=fr_FR,en_US
    volumes:
      - ./trainingData:/usr/share/tessdata
      - ./configs:/configs
      - ./logs:/logs
      - ./customFiles:/customFiles
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.stirling-pdf.rule=Host(`stirling.kamitbrains.fr`) || Host(`stirling-pdf.kamitbrains.fr`) || Host(`pdf2.kamitbrains.fr`)"
      - "traefik.http.routers.stirling-pdf.entrypoints=websecure"
      - "traefik.http.routers.stirling-pdf.tls.certresolver=letsencrypt"
      - "traefik.http.routers.stirling-pdf.middlewares=crowdsec-bouncer@file,tinyauth-auth@docker"
      - "traefik.http.services.stirling-pdf.loadbalancer.server.port=8080"
```

---

## 📊 Surveillance & Intégrations

- **Homepage Dashboard** : Carte dédiée sous `Core Services` (`stirling.kamitbrains.fr`).
- **Uptime Kuma** : Monitor #12 (`Stirling-PDF Suite`) configuré avec alertes Push Ntfy.
