---
title: "Docker Examples — Collection de Stacks Docker Compose & Ansible"
description: "Collection complète de configurations Docker Compose et rôles Ansible pour services auto-hébergés par Aurélien NKUMBE"
tags: docker, compose, ansible, self-hosted, devops
lang: fr
---

# Docker Examples Collection

A comprehensive collection of production-ready Docker Compose configurations for self-hosted services, organized by functional categories. This repository provides quick deployment solutions for various infrastructure components, development tools, and business applications.

## 🏗️ Repository Structure

```text
docker-examples/
├── ansible/                          # Automated Ansible deployment suite (Traefik, Glances, Arcane, Socket Proxy, systemd, SSL)
├── compose/                          # Production Docker Compose stacks organized into 18 categories
│   ├── 01-infrastructure/            # Bind9 DNS, Nginx Certbot, Traefik
│   ├── 02-container-orchestration/   # Arcane PaaS Manager, Portainer, Coolify, Dokploy, K8s Cert-Manager, Longhorn
│   ├── 03-iot-smart-home/            # Home Assistant, ChangeDetection.io
│   ├── 04-network-management/        # Asterisk VoIP
│   ├── 05-monitoring-reporting/      # Checkmk, Uptime Kuma, Glances, Observability (Prometheus/Grafana), SonarQube
│   ├── 06-ai/                        # Ollama Local, Open WebUI, Jupyter Notebooks, DGX SSH Tunnel
│   ├── 07-automation/                # Workflow automation, CI/CD, Cron & PM2 Scheduling
│   ├── 08-code-management/           # Gitea, Docker Registry, JFrog Artifactory
│   ├── 09-app-server-management/     # Business Apps (Odoo ERP), Content Management (WordPress, Drupal)
│   ├── 10-databases/                 # PostgreSQL, CouchDB Cluster, CockroachDB
│   ├── 11-security-identity/         # Keycloak, Zitadel, SuperTokens, Wazuh SIEM, ClamAV, Socket Proxy
│   ├── 12-document-management/       # Paperless-ngx
│   ├── 13-api-gateway/               # Traefik, Kong, Tyk, WSO2 AM, Hasura GraphQL, Hoppscotch
│   ├── 14-mail-services/             # Mailpit, Docker Mailserver, Mailcatcher, Mailu
│   ├── 15-media-storage/             # MinIO S3, Erugo File Sharing, Static Files Server, S3FS Volume
│   ├── 16-development-tools/         # IT-Tools, Excalidraw
│   ├── 17-data-processing/           # Kafka + Logstash real-time processing stack
│   └── 18-communication/             # Novu notification engine
├── docs/                             # MkDocs source documentation & Arcane templates registry
├── helm/                             # Kubernetes Helm charts
├── kubernetes/                       # Native Kubernetes manifests
├── packer/                           # VM & Container image builder templates
├── scripts/                          # Cloudflare DNS CLI & Registry generator scripts
└── terraform/                        # Infrastructure as Code templates
```

### Key Service Categories

- **[Ansible Automation](ansible/)** - Production playbook suite for Traefik, Glances, Arcane PaaS, Docker Socket Proxy, and Let's Encrypt SSL.
- **[Container Orchestration](compose/02-container-orchestration/)** - [Arcane](compose/02-container-orchestration/arcane/), [Portainer](compose/02-container-orchestration/portainer/), [Coolify](compose/02-container-orchestration/coolify/), [Dokploy](compose/02-container-orchestration/dokploy/).
- **[AI & LLM Platforms](compose/06-ai/)** - [Ollama Local](compose/06-ai/ollama-local/), [Open WebUI](compose/06-ai/open-webui/), [Jupyter Notebooks](compose/06-ai/jupyter/), [DGX SSH Tunnel](compose/06-ai/dgx-ollama-tunnel/).
- **[API Management & Gateways](compose/13-api-gateway/)** - [Traefik](compose/13-api-gateway/api-gateways/), [Kong](compose/13-api-gateway/api-gateways/), [Hasura](compose/13-api-gateway/graphql/).
- **[Security & Identity](compose/11-security-identity/)** - [Keycloak](compose/11-security-identity/identity-providers/), [Zitadel](compose/11-security-identity/identity-providers/), [Wazuh SIEM](compose/11-security-identity/wazuh/), [Docker Socket Proxy](compose/11-security-identity/security-tools/).
- **[Data Processing & Analytics](compose/17-data-processing/)** - [Kafka + Logstash Stack](compose/17-data-processing/kafka-logstash/).
- **[Cloudflare DNS CLI](scripts/cloudflare_dns.py)** - Automated DNS management powered by official Cloudflare Python SDK v5.

## 🚀 Quick Start

### Prerequisites
- Docker Engine 20.10+
- Docker Compose 2.0+
- Sufficient system resources (varies by service)

### Basic Usage
1. Navigate to any service directory:
   ```bash
   cd api-managment/kong/
   ```

2. Start the service:
   ```bash
   docker-compose up -d
   ```

3. Check service status:
   ```bash
   docker-compose ps
   ```

### Local Domain Management

Install [hostctl](https://guumaster.github.io/hostctl/docs/installation/) for professional local domain management:

```bash
# Add all service domains
hostctl add domains apps apps.local hub.apps.local \
        db.apps.local mysql.apps.local \
        docker.apps.local portainer.apps.local arcane.apps.local \
        s3.apps.local minio.apps.local \
        kong.apps.local admin.kong.apps.local manage.kong.apps.local api.kong.apps.local \
        jupyter.apps.local \
        mail.apps.local
```

## 🔧 Production-Ready Services

Several services are configured for production deployment:

### Kafka + Logstash Stack
- 3-broker Kafka cluster with Zookeeper
- Real-time data processing for EmotiBit data
- Automatic log rotation and monitoring
- Emergency cleanup scripts

### CouchDB Cluster
- 3-node CouchDB cluster with HAProxy load balancer
- Automatic cluster initialization
- Persistent data storage

### Arcane Docker Dashboard
- Modern, lightweight PaaS dashboard for container orchestration and management
- Hardened security configuration using Tecnativa Docker Socket Proxy
- Integrated out-of-the-box with custom template registries

### Mail Servers
- Complete SMTP/IMAP solutions
- Anti-spam and security configurations
- Web administration interfaces


## 🎛️ PaaS Integration (Arcane)

This repository includes a production-ready **Arcane** container management setup (under `compose/02-container-orchestration/arcane/`). All web configurations in this repository are pre-configured with custom branding metadata (using the `x-arcane:` block and community-approved WebP icons).

You can load all 60+ configurations from this repository directly as templates in your Arcane dashboard by registering the custom template registry:
* **Registry URL**: `https://nkaurelien.github.io/docker-examples/arcane-registry.json`

To auto-deploy Arcane with this registry pre-configured, simply run:
```bash
make arcane-start
```

## 📚 Documentation

### Online Documentation

Full documentation is available at: **[https://nkaurelien.github.io/docker-examples/](https://nkaurelien.github.io/docker-examples/)**

### Run Documentation Locally

```bash
# Install dependencies (with uv recommended)
uv venv && source .venv/bin/activate
uv pip install -r requirements-docs.txt

# Or with pip
pip install -r requirements-docs.txt

# Serve documentation
mkdocs serve
```

Documentation available at: [http://127.0.0.1:8000](http://127.0.0.1:8000)

### Service Documentation

Each service directory contains:
- `README.md` or `readme.md` - Service-specific documentation
- `compose.yml` or `docker-compose.yml` - Docker Compose configuration
- Configuration files and initialization scripts
- Environment variable examples

For comprehensive setup and troubleshooting information, see [CLAUDE.md](CLAUDE.md).

## 🛠️ Common Operations

### View all running services
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Monitor resource usage
```bash
docker stats
```

### Cleanup unused resources
```bash
docker system prune -f
docker volume prune -f
```

### Emergency disk space cleanup (Kafka)
```bash
cd kafka-logstash/
./cleanup_kafka.sh
```

## 🔗 Useful Resources

### Foundation Projects
- [CNCF Projects](https://www.cncf.io/projects/) - Cloud Native Computing Foundation
- [Apache Open Source Projects](https://projects.apache.org/projects.html)

### Self-Hosting Resources
- [11 Open-Source SaaS Killers](https://withcodeexample.com/11-open-source-saas-killer-selfhost-with-docker-2/?utm_source=medium&utm_medium=article&utm_campaign=free_read)
- [12 Open Source Auth Tools](https://www.permit.io/blog/top-12-open-source-auth-tools)

## 💡 Proposed & Recommended Services to Add

We are always looking to expand this repository with modern, production-ready configurations. Below is a curated list of high-value open-source tools that would be excellent additions:

| Category | Recommended Project | Description | Target Use Case |
|---|---|---|---|
| **AI & LLM** | [Ollama](https://ollama.com/) | Run local LLMs (Llama 3, Mistral) in Docker | Core local AI backend |
| | [Flowise](https://flowiseai.com/) / [Langflow](https://www.langflow.org/) | Low-code GUI for building RAG applications | AI Agent orchestration |
| **BaaS / Low-Code** | [Supabase](https://supabase.com/) | Open-source Firebase alternative (Postgres, Auth, Storage) | Full-stack rapid app backend |
| | [Appwrite](https://appwrite.io/) | Self-hosted backend-as-a-service for web/mobile apps | Unified backend suite |
| **Databases** | [ClickHouse](https://clickhouse.com/) | Column-oriented DBMS for high-performance analytics | Big Data & Logging backend |
| | [Meilisearch](https://www.meilisearch.com/) | Lightning-fast search engine (Elasticsearch alternative) | Instant search integration |
| **Security & Auth** | [Authentik](https://goauthentik.io/) | Unified, identity provider with SSO | Secure Gateway portal |
| | [Vault / OpenBao](https://openbao.org/) | Secrets management and data protection | Zero-trust secrets storage |
| **Observability** | [Loki & Promtail](https://grafana.com/oss/loki/) | Log aggregation system (part of the LGTM stack) | Centralized application logging |

## 🤝 Contributing

1. Each service should be self-contained in its own directory
2. Include comprehensive documentation in service README files
3. Use consistent Docker Compose patterns
4. Test configurations before committing
5. Follow security best practices for production deployments

## 📄 License

This collection is provided as-is for educational and development purposes. Individual services maintain their respective licenses.



