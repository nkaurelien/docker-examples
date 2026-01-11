# Docker Examples

Collection de configurations Docker Compose prêtes à l'emploi pour services self-hosted.

## Categories

### API Management

- **[Traefik](services/api-management/traefik/index.md)** - Reverse proxy avec auto-discovery
- **[Kong](services/api-management/kong.md)** - API Gateway
- **[Hasura](services/api-management/hasura.md)** - GraphQL Engine

### Orchestration

- **[Portainer](services/orchestration/portainer.md)** - Docker/Kubernetes UI
- **[Rancher](services/orchestration/rancher.md)** - Kubernetes management

### Monitoring

- **[Glances](services/monitoring/glances.md)** - System monitoring

### Mail Servers

- **[Mailpit](services/mail/mailpit.md)** - Email testing (dev)
- **[Docker Mailserver](services/mail/docker-mailserver.md)** - Production mail server

### Databases

- **[CouchDB Cluster](services/databases/couchdb.md)** - NoSQL cluster
- **[PostgreSQL](services/databases/postgresql.md)** - SQL database

### Security

- **[NeuVector](services/security/neuvector.md)** - Container security platform
- **[Socket Proxy](services/security/socket-proxy.md)** - Secure Docker API access

### Authentication

- **[Keycloak](services/auth/keycloak.md)** - Identity management
- **[Zitadel](services/auth/zitadel.md)** - Cloud-native IAM

## Quick Start

```bash
# Clone the repository
git clone https://github.com/nkaurelien/docker-examples.git
cd docker-examples

# Start a service
cd api-managment/traefik
docker compose up -d
```

## Documentation

- [Docker Essentials](docker/essentials.md) - Concepts de base Docker Compose
- [Docker Capabilities](docker/capabilities.md) - Linux capabilities et sécurité

## Structure du Repository

```
docker-examples/
├── api-managment/          # API gateways (Traefik, Kong, Hasura)
├── auth-management/        # Authentication (Keycloak, Zitadel)
├── databases/              # Databases (CouchDB, PostgreSQL)
├── mail-servers/           # Mail (Mailpit, Docker Mailserver)
├── monitoring/             # Monitoring (Glances)
├── orchestration/          # Container management (Portainer, Rancher)
├── security/               # Security tools (NeuVector)
├── surveillance/           # Change detection
└── docs/                   # Documentation (MkDocs)
```
