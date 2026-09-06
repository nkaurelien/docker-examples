# BentoPDF — Privacy-First Client-Side PDF Toolkit

**BentoPDF** est un outil de manipulation de fichiers PDF (fusion, division, compression, extraction, conversion) 100% côté client (Browser Client-Side), garantissant la confidentialité absolue de vos documents.

---

## 🚀 Fonctionnalités principales

- **Confidentialité totale** : Aucun traitement de fichier n'est effectué côté serveur ; tout se déroule directement dans le navigateur du client.
- **Opérations PDF complètes** : Fusion, découpage, réorganisation de pages, protection par mot de passe, extraction de texte/images, filigranes.
- **Performance** : Exécution immédiate sans envoi de fichiers sur le réseau.
- **Intégration SSO** : Protégé par **TinyAuth SSO** (`tinyauth-auth@docker`) et **CrowdSec Bouncer**.

---

## 🌐 URLs & Accès

- **URL Principale** : [https://pdf.kamitbrains.fr](https://pdf.kamitbrains.fr)
- **Alias de domaine** : [https://bento.kamitbrains.fr](https://bento.kamitbrains.fr)
- **Authentification** : TinyAuth SSO (`admin@kamitbrains.fr` / `admin`)

---

## 🛠️ Configuration Docker & Ansible

Le rôle Ansible se trouve dans `ansible/roles/bentopdf`.

### Service `docker-compose.yml`

```yaml
services:
  bentopdf:
    image: bentopdfteam/bentopdf:latest
    container_name: bentopdf
    restart: unless-stopped
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.bentopdf.rule=Host(`pdf.kamitbrains.fr`) || Host(`bento.kamitbrains.fr`)"
      - "traefik.http.routers.bentopdf.entrypoints=websecure"
      - "traefik.http.routers.bentopdf.tls.certresolver=letsencrypt"
      - "traefik.http.routers.bentopdf.middlewares=crowdsec-bouncer@file,tinyauth-auth@docker"
      - "traefik.http.services.bentopdf.loadbalancer.server.port=8080"
```

---

## 📊 Surveillance & Intégrations

- **Homepage Dashboard** : Carte dédiée sous `Core Services` (`pdf.kamitbrains.fr`).
- **Uptime Kuma** : Monitor #11 (`BentoPDF Toolkit`) configuré avec alertes Push Ntfy.
