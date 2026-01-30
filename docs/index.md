# Docker Examples

Collection de configurations Docker Compose prêtes à l'emploi pour services self-hosted.

## Categories

### Infrastructure

- **[Bind9 DNS](services/infrastructure/bind9.md)** - Serveur DNS local

### Orchestration

- **[Portainer](services/orchestration/portainer.md)** - Docker/Kubernetes UI
- **[Rancher](services/orchestration/rancher.md)** - Kubernetes management
- **[Coolify](services/orchestration/coolify.md)** - PaaS self-hosted (alt. Heroku/Vercel)
- **[Dokploy](services/orchestration/dokploy.md)** - PaaS self-hosted (alt. Netlify)
- **[Longhorn](services/orchestration/longhorn.md)** - Stockage distribué Kubernetes
- **[cert-manager](services/orchestration/cert-manager.md)** - Gestion certificats TLS Kubernetes

### IoT & Smart Home

- **[Home Assistant](services/iot/home-assistant.md)** - Plateforme domotique avec Zigbee2MQTT

### Network Management

- **[Asterisk](services/network/asterisk.md)** - Serveur VoIP PBX

### Monitoring

- **[Glances](services/monitoring/glances.md)** - System monitoring
- **[Checkmk](services/monitoring/checkmk.md)** - IT infrastructure monitoring
- **[Uptime Kuma](services/monitoring/uptime-kuma.md)** - Uptime monitoring (alt. Pingdom)

### AI & Machine Learning

- *À venir* - Ollama, LocalAI, Stable Diffusion

### Automation

- *À venir* - n8n, Airflow, Temporal

### Code Management

- **[Gitea](services/code-management/gitea.md)** - Git hosting (alt. GitHub/GitLab)

### App & Server Management

- *À venir* - WordPress, Drupal, Odoo

### Databases

- **[CouchDB Cluster](services/databases/couchdb.md)** - NoSQL cluster
- **[PostgreSQL](services/databases/postgresql.md)** - SQL database

### Security & Identity

- **[NeuVector](services/security/neuvector.md)** - Container security platform
- **[Socket Proxy](services/security/socket-proxy.md)** - Secure Docker API access

### Document Management

- *À venir* - Paperless-ngx, Nextcloud

### API Gateway

- **[Traefik](services/api-management/traefik/index.md)** - Reverse proxy avec auto-discovery
- **[Kong](services/api-management/kong.md)** - API Gateway
- **[Hasura](services/api-management/hasura.md)** - GraphQL Engine

### Mail Servers

- **[Mailpit](services/mail/mailpit.md)** - Email testing (dev)
- **[Docker Mailserver](services/mail/docker-mailserver.md)** - Production mail server

### Media & Storage

- **[Erugo](services/file-sharing/erugo.md)** - File sharing
- *À venir* - MinIO, PhotoPrism, Jellyfin

### Data Processing

- *À venir* - Kafka, Spark, Logstash

### Communication

- *À venir* - Mattermost, Rocket.Chat, Matrix

### Authentication

- **[Keycloak](services/auth/keycloak.md)** - Identity management
- **[Passbolt](services/auth/passbolt.md)** - Password manager
- **[Zitadel](services/auth/zitadel.md)** - Cloud-native IAM

### Development Tools

- **[IT-Tools](services/dev-tools/it-tools.md)** - Outils développeur en ligne

### Surveillance

- **[ChangeDetection.io](services/surveillance/changedetection.md)** - Website change monitoring

## Quick Start

```bash
# Clone the repository
git clone https://github.com/nkaurelien/docker-examples.git
cd docker-examples

# Start a service
cd 13-api-gateway/traefik
docker compose up -d
```

## Documentation

- [Docker Essentials](docker/essentials.md) - Concepts de base Docker Compose
- [Docker Capabilities](docker/capabilities.md) - Linux capabilities et sécurité

## Structure du Repository

```
docker-examples/
├── 01-infrastructure/        # DNS, réseau de base
├── 02-container-orchestration/  # Portainer, Rancher, Coolify, K8s tools
├── 03-iot-smart-home/        # Home Assistant, Zigbee
├── 04-network-management/    # Asterisk VoIP
├── 05-monitoring-reporting/  # Glances, Checkmk, Uptime Kuma
├── 06-ai/                    # AI/ML platforms
├── 07-automation/            # Workflow automation
├── 08-code-management/       # Gitea, GitLab
├── 09-app-server-management/ # CMS, ERP
├── 10-databases/             # PostgreSQL, CouchDB
├── 11-security-identity/     # Keycloak, Zitadel
├── 12-document-management/   # Paperless, DMS
├── 13-api-gateway/           # Traefik, Kong, Hasura
├── 14-mail-services/         # Mailpit, Docker Mailserver
├── 15-media-storage/         # MinIO, file sharing
├── 16-development-tools/     # IT-Tools
├── 17-data-processing/       # Kafka, Spark
├── 18-communication/         # Chat, video
└── docs/                     # Documentation (MkDocs)
```

## Makefile

Commandes disponibles:

```bash
make docs          # Installer deps + servir la doc
make docs-deploy   # Déployer sur GitHub Pages
make docker-clean  # Nettoyer ressources Docker
make lint          # Linter les Dockerfiles
make help          # Voir toutes les commandes
```
