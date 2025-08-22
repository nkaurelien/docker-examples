# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive collection of Docker examples and self-hosted services, organized by functional categories. Each directory contains production-ready Docker Compose configurations for different types of services.

## Architecture

The repository follows a modular architecture where each service category is isolated in its own directory:

- **api-management/**: API gateway solutions (Hasura, Kong, Tyk, WSO2)
- **auth-management/**: Authentication services (Keycloak, Kratos, SuperTokens, Zitadel)
- **databases/**: Database solutions (CockroachDB, CouchDB cluster, PostgreSQL)
- **kafka-logstash/**: Real-time data processing pipeline with Kafka cluster and Logstash
- **mail-servers/**: Email server solutions (Docker Mailserver, Mailcatcher, Mailu)
- **statics-files-server/**: Static file serving with multiple backend/frontend options

## Common Commands

### Docker Compose Operations
Most services use either `compose.yml` or `docker-compose.yml`:
```bash
# Start services
docker-compose up -d
# or
docker compose up -d

# View status
docker-compose ps

# View logs
docker-compose logs -f [service_name]

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Rebuild and restart
docker-compose down && docker-compose up -d --build
```

### Service-Specific Commands

#### Kafka-Logstash Stack
```bash
# Start the complete Kafka cluster
cd kafka-logstash/
docker-compose up -d

# Check cluster setup
docker-compose logs kafka-setup

# List Kafka topics
docker exec kafka1 kafka-topics --list --bootstrap-server localhost:9092

# Monitor topic
docker exec kafka1 kafka-console-consumer --topic Emotibit_rawdata --from-beginning --bootstrap-server localhost:9092

# Cleanup (emergency)
./cleanup_kafka.sh
```

#### CouchDB Cluster
```bash
cd databases/couchdb-cluster/
docker-compose up -d
./init-cluster.sh  # Initialize cluster after containers start
```

#### Docker Registry
```bash
cd docker-registry/
# Push images using the provided script
./push.sh

# Tag and push manually
docker tag <image> 192.168.0.201:25000/<image>:<tag>
docker push 192.168.0.201:25000/<image>:<tag>
```

### Monitoring and Diagnostics
```bash
# Check disk usage (important for Kafka)
df -h /

# Docker system info
docker system df

# Container resource usage
docker stats

# Network connectivity
docker exec <container> netstat -tulpn
```

## Key Configuration Patterns

### Environment Management
- Services use `.env` files or environment variables in compose files
- Example files are provided as `.example` extensions
- Check individual service READMEs for specific configuration requirements

### Network Architecture
- Most services use Docker networks for internal communication
- External access is configured via port mapping
- Some services (like Kong) have multiple network configurations

### Volume Management
- Database services mount persistent volumes
- Configuration files are typically mounted from `./config/` directories
- Log rotation is configured for production deployments

### Host Management
The repository includes `hostctl` setup for local domain management:
```bash
hostctl add domains apps apps.local hub.apps.local db.apps.local mysql.apps.local docker.apps.local portainer.apps.local s3.apps.local minio.apps.local kong.apps.local admin.kong.apps.local manage.kong.apps.local api.kong.apps.local jupyter.apps.local mail.apps.local
```

## Production Considerations

### Kafka-Logstash (Production Ready)
- 3-broker Kafka cluster with Zookeeper coordination
- Automatic log rotation and disk space management
- Monitoring via Kafka UI on port 8081
- Emergency cleanup scripts for disk space issues

### CouchDB Cluster
- Requires Erlang cookie synchronization across nodes
- Persistent volume mounting for `/opt/couchdb/etc/local.d`
- Cluster initialization script required after container startup

### Resource Requirements
- Kafka stack: Minimum 8GB RAM, 50GB disk space
- Logstash: Configured with 2GB heap per instance
- CouchDB: Requires proper cookie configuration for clustering

## Troubleshooting

### Common Issues
1. **Disk space**: Use `df -h /` and cleanup scripts in kafka-logstash/
2. **Network connectivity**: Check Docker networks and port conflicts
3. **Service dependencies**: Ensure dependent services (like Zookeeper) start first
4. **Volume permissions**: Check mounted volume permissions for database services

### Service-Specific Troubleshooting
- **Kafka**: Check Zookeeper logs first, verify topic creation
- **CouchDB**: Verify Erlang cookie consistency across nodes
- **Docker Registry**: Configure insecure registries in `/etc/docker/daemon.json`