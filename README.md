
# Docker Examples Collection

A comprehensive collection of production-ready Docker Compose configurations for self-hosted services, organized by functional categories. This repository provides quick deployment solutions for various infrastructure components, development tools, and business applications.

## 🏗️ Repository Structure

### API Management
- **[Hasura](api-managment/hasura/)** - GraphQL API with real-time subscriptions
- **[Hoppscotch](api-managment/hoppscotch/)** - Open-source API development ecosystem
- **[Kong](api-managment/kong/)** - Cloud-native API gateway with admin UI
- **[Tyk](api-managment/tyk/)** - Open-source API gateway and management platform
- **[WSO2 API Manager](api-managment/wso2am/)** - Full lifecycle API management

### Authentication & Authorization
- **[Keycloak](auth-managment/keycloak/)** - Identity and access management
- **[Kratos](auth-managment/kratos/)** - Cloud native identity management
- **[SuperTokens](auth-managment/super-token/)** - Open-source authentication solution
- **[Zitadel](auth-managment/zitadel/)** - Identity infrastructure platform

### Databases
- **[CockroachDB](databases/cockroach/)** - Distributed SQL database
- **[CouchDB Cluster](databases/couchdb-cluster/)** - Multi-node CouchDB setup with HAProxy
- **[PostgreSQL](databases/postgres/)** - PostgreSQL with backup/restore utilities

### Data Processing & Analytics
- **[Kafka + Logstash](kafka-logstash/)** - Production-ready Kafka cluster with real-time data processing
- **[Grafana](grafana/)** - Monitoring and observability platform
- **[Jupyter](jupyter/)** - Data science notebooks with Spark integration

### Development Tools
- **[Jenkins](jenkins/)** - CI/CD automation server
- **[SonarQube](sonarcube/)** - Code quality and security analysis
- **[Docker Registry](docker-registry/)** - Private Docker image registry with UI
- **[Portainer](portainer/)** - Docker container management UI

### Communication & Collaboration
- **[Mail Servers](mail-servers/)** - Complete email solutions (Docker Mailserver, Mailcatcher, Mailu)
- **[Excalidraw](excalidraw/)** - Collaborative drawing tool (on-premises alternative to draw.io)

### Storage & File Management
- **[MinIO S3](minio-s3/)** - S3-compatible object storage
- **[Static Files Server](statics-files-server/)** - Multi-backend static file serving
- **[S3FS Volume](using-s3fs-volume/)** - Mount S3 buckets as local volumes

### Business Applications
- **[Odoo ERP](odoo-erp/)** - Complete business management suite
- **[Drupal](drupal/)** - Content management system
- **[WordPress](mysql-wordpress/)** - WordPress with MySQL

### Infrastructure Services
- **[DNS Server](dnsServer/)** - Local DNS management
- **[Nginx Proxy Manager](nginx-proxy-manager/)** - Reverse proxy with SSL management
- **[Cron Jobs](cronjob/)** - Scheduled task management with PM2 and multiple queue systems

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
        docker.apps.local portainer.apps.local \
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

### Mail Servers
- Complete SMTP/IMAP solutions
- Anti-spam and security configurations
- Web administration interfaces

## 📚 Documentation

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

## 🤝 Contributing

1. Each service should be self-contained in its own directory
2. Include comprehensive documentation in service README files
3. Use consistent Docker Compose patterns
4. Test configurations before committing
5. Follow security best practices for production deployments

## 📄 License

This collection is provided as-is for educational and development purposes. Individual services maintain their respective licenses.



