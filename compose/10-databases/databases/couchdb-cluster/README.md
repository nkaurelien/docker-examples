# CouchDB Cluster Example with Management UI

A complete CouchDB cluster setup with 3 nodes, automatic initialization, and a comprehensive management interface.

## Features

- 🔄 **3-Node Cluster**: Automatic setup with load balancing and replication
- 📊 **Management UI**: Streamlit-based CouchDB Manager for backups, restore, sync
- 🌐 **Variable Network**: Configurable IP addresses and network settings
- 🔐 **Secure Setup**: Environment-based configuration with secrets
- 🛠️ **Easy Management**: Makefile with common operations

## Quick Start

1. **Setup Environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

2. **Start the Cluster**:

   Using Makefile (recommended):
   ```bash
   # Quick start with everything
   make quick-start

   # Or with backup scheduler
   make quick-start-with-backup
   ```

   Using docker-compose directly:
   ```bash
   # Create network if not exists
   docker network create asone4health_network --subnet=172.24.0.0/16

   # Start cluster
   docker-compose up -d

   # Or with backup scheduler
   docker-compose --profile backup up -d
   ```

3. **Access Services**:
   - **CouchDB Node 0**: http://localhost:5984/_utils (admin/admin123)
   - **CouchDB Node 1**: http://localhost:5985/_utils
   - **CouchDB Node 2**: http://localhost:5986/_utils
   - **Management UI**: http://localhost:8501 (automatically started with cluster)

## Configuration

### Environment Variables

Key variables in `.env`:

```env
# Project Configuration
COMPOSE_PROJECT_NAME=couchdb-cluster-example
COUCHDB_NODE_NAME=couchdb-cluster-example
PORT_BASE=5984

# Authentication
COUCHDB_USER=admin
COUCHDB_PASSWORD=admin123

# Network (customize to avoid conflicts)
NETWORK_SUBNET=172.24.0.0/16
NODE0_IP=172.24.0.20
NODE1_IP=172.24.0.21
NODE2_IP=172.24.0.22
CLUSTER_INIT_IP=172.24.0.23
MANAGER_IP=172.24.0.24
BACKUP_SERVICE_IP=172.24.0.25
```

### Port Mapping

- **Node 0**: `PORT_BASE+0` (default: 5984)
- **Node 1**: `PORT_BASE+1` (default: 5985)
- **Node 2**: `PORT_BASE+2` (default: 5986)

## Management UI

The CouchDB Manager is **automatically included** as a Docker service and provides a comprehensive web interface for:

- **Dashboard**: View database statistics across all nodes
- **Backup**: Create local backups with full attachment support
- **Restore**: Restore databases from backup files (handles all formats)
- **Sync**: Synchronize databases between different instances
- **Delete**: Safely remove databases with multiple confirmations
- **Real-time monitoring**: Live progress tracking and detailed logging

### Access

- **Web Interface**: http://localhost:8501 (starts automatically with cluster)
- **No installation required**: Everything runs in Docker containers

### Manual Installation (Optional)

If you want to run the UI outside Docker:

```bash
pip install -r requirements.txt
streamlit run couchdb_manager.py
```

## Cluster Architecture

```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│    CouchDB Node 0   │    │    CouchDB Node 1   │    │    CouchDB Node 2   │
│   (Coordinator)     │    │                     │    │                     │
│  172.24.0.20:5984   │    │  172.24.0.21:5985   │    │  172.24.0.22:5986   │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
           │                           │                           │
           └───────────────────────────┼───────────────────────────┘
                                      │
                          ┌─────────────────────┐
                          │   Cluster Init      │
                          │  172.24.0.23        │
                          │  (Auto-setup)       │
                          └─────────────────────┘
                                      │
                          ┌─────────────────────┐
                          │  CouchDB Manager    │
                          │  172.24.0.24:8501   │
                          │  (Streamlit UI)     │
                          └─────────────────────┘
                                      │
                          ┌─────────────────────┐
                          │      Ofelia         │
                          │  172.24.0.25        │
                          │  (Backup Scheduler) │
                          └─────────────────────┘
```

### Services Overview

| Service | URL | IP Address | Purpose |
|---------|-----|------------|---------|
| **Node 0** | http://localhost:5984/_utils | 172.24.0.20 | Primary CouchDB node (coordinator) |
| **Node 1** | http://localhost:5985/_utils | 172.24.0.21 | Secondary CouchDB node |
| **Node 2** | http://localhost:5986/_utils | 172.24.0.22 | Secondary CouchDB node |
| **Cluster Init** | - | 172.24.0.23 | Automatic cluster initialization |
| **Manager** | http://localhost:8501 | 172.24.0.24 | Web-based management interface |
| **Ofelia** | - | 172.24.0.25 | Automated backup scheduler (optional) |

## Automated Backups with Ofelia

The cluster includes Ofelia job scheduler for automated backups. By default, it's configured as an optional profile.

### Enable Automated Backups

Using Makefile commands (recommended):

```bash
# Start cluster with backup scheduler
make up-with-backup

# Or start backup scheduler on running cluster
make backup-service-start

# Check backup scheduler status
make backup-service-status

# View Ofelia logs
make backup-service-logs

# Stop backup scheduler
make backup-service-stop

# Run backup immediately (without waiting for schedule)
make backup-now
```

Using docker-compose directly:

```bash
# Start Ofelia service with backup profile
docker-compose --profile backup up -d ofelia

# Check Ofelia status
docker-compose ps ofelia

# View Ofelia logs
docker-compose logs ofelia
```

### Backup Configuration

#### Two Configuration Methods (Choose One)

Ofelia supports two mutually exclusive ways to configure jobs. You must choose one method:

---

#### Method 1: Docker Labels (Currently Active - Recommended)

**How it works:**
- Ofelia runs in `daemon --docker` mode
- It scans all running containers and reads their Docker labels
- Jobs are discovered automatically from container labels
- No configuration file needed

**Current Configuration:**

In [docker-compose.yml](docker-compose.yml), the Ofelia service is configured as:

```yaml
ofelia:
  image: mcuadros/ofelia:latest
  command: daemon --docker    # <-- Docker labels mode
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
  # NO config file mounted
```

The backup job is defined via labels on the `couchdb-0` service:

```yaml
couchdb-0:
  labels:
    ofelia.enabled: "true"
    ofelia.job-exec.couchdb-backup-daily.schedule: "0 2 * * *"
    ofelia.job-exec.couchdb-backup-daily.command: "/opt/scripts/backup-job.sh"
```

**How to modify the schedule or command:**

1. Edit the labels in `docker-compose.yml` (couchdb-0 service)
2. Recreate the container with new labels:
   ```bash
   docker-compose up -d couchdb-0  # Recreate with new labels
   docker-compose restart ofelia    # Reload Ofelia to discover new labels
   ```
3. Verify the job is registered:
   ```bash
   make backup-service-status
   ```

**Advantages:**
- ✅ Infrastructure-as-code (everything in docker-compose.yml)
- ✅ No external configuration files
- ✅ Auto-discovery of containers
- ✅ Easy to version control

---

#### Method 2: Configuration File (Alternative)

**How it works:**
- Ofelia runs in `daemon --config` mode
- It reads jobs from `/etc/ofelia/config.ini`
- You must specify the exact container name
- Labels are ignored in this mode

**To switch to this method:**

1. **Update the Ofelia service** in [docker-compose.yml](docker-compose.yml):

   ```yaml
   ofelia:
     image: mcuadros/ofelia:latest
     command: daemon --config    # <-- Config file mode
     volumes:
       - /var/run/docker.sock:/var/run/docker.sock:ro
       - ./config/ofelia.ini:/etc/ofelia/config.ini:ro  # Mount config
   ```

2. **Remove labels** from the couchdb-0 service (optional but cleaner):

   ```yaml
   couchdb-0:
     # Remove or comment out these labels:
     # labels:
     #   ofelia.enabled: "true"
     #   ...
   ```

3. **Create/Edit** [config/ofelia.ini](config/ofelia.ini):

   ```ini
   [job-exec "couchdb-backup-daily"]
   # Daily backup job at 2 AM
   schedule = 0 2 * * *
   container = couchdb-cluster-example-couchdb-0-1
   command = /opt/scripts/backup-job.sh
   ```

4. **Restart Ofelia**:
   ```bash
   docker-compose restart ofelia
   make backup-service-status
   ```

**Advantages:**
- ✅ Centralized configuration
- ✅ Can define multiple jobs in one file
- ✅ Easier to manage many jobs

**Note:** The container name must match exactly. Get it with:
```bash
docker ps --filter "name=couchdb-0"
```

---

#### Comparison Table

| Feature | Docker Labels (`daemon --docker`) | Config File (`daemon --config`) |
|---------|-----------------------------------|----------------------------------|
| Configuration location | docker-compose.yml | config/ofelia.ini |
| Auto-discovery | ✅ Yes | ❌ No (must specify container name) |
| Hot reload | Restart Ofelia + recreate container | Restart Ofelia only |
| Multiple jobs | Multiple label sets | Single file |
| Currently active | ✅ **Yes** | ❌ No |

**Schedule Format**: `minute hour day month weekday` (cron syntax)
- `0 2 * * *` = Daily at 2:00 AM
- `0 */6 * * *` = Every 6 hours
- `0 0 * * 0` = Weekly (Sundays at midnight)

### Backup Script

Create your backup script at [scripts/backup-job.sh](scripts/backup-job.sh):

```bash
#!/bin/bash
# Example backup script
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/backups"
# Add your backup logic here
```

## Makefile Commands

The project includes a comprehensive Makefile for easy cluster management. Run `make help` to see all available commands:

### Quick Start Commands
```bash
make quick-start              # Complete setup: network + cluster + init
make quick-start-with-backup  # Quick start with Ofelia backup scheduler
```

### Cluster Management
```bash
make up                # Start cluster (without backup)
make up-with-backup    # Start cluster with backup scheduler
make down              # Stop and remove cluster
make restart           # Restart cluster
make status            # Show cluster status
make logs              # Show cluster logs
```

### Backup Scheduler (Ofelia)
```bash
make backup-service-start    # Start Ofelia backup scheduler
make backup-service-stop     # Stop Ofelia backup scheduler
make backup-service-status   # Show Ofelia status and jobs
make backup-service-logs     # View Ofelia logs
make backup-now              # Run backup immediately
```

**Note:** Ofelia uses Docker labels to configure jobs. If you modify the backup schedule or command in `docker-compose.yml`, recreate the couchdb-0 container and restart Ofelia:
```bash
docker-compose up -d couchdb-0
docker-compose restart ofelia
```

### Manual Backup/Sync
```bash
make backup              # Backup local databases
make list-backups        # List available backups
make clean-backups       # Clean old backups
```

### Utilities
```bash
make test-cluster   # Test cluster connectivity
make shell          # Open shell in CouchDB node 0
make manager        # Launch CouchDB Manager UI
```

## Common Operations

### Check Cluster Status

```bash
# Via API
curl http://admin:admin123@localhost:5984/_membership

# Expected response:
{
  "all_nodes": ["couchdb@couchdb-0"],
  "cluster_nodes": ["couchdb@couchdb-0", "couchdb@couchdb-1", "couchdb@couchdb-2"]
}
```

### Create a Database

```bash
# Create database (will be replicated across nodes)
curl -X PUT http://admin:admin123@localhost:5984/testdb

# Verify on other nodes
curl http://admin:admin123@localhost:5985/testdb
curl http://admin:admin123@localhost:5986/testdb
```

## Troubleshooting

### Cluster Not Initializing

1. **Check Logs**:
   ```bash
   docker-compose logs cluster-init
   ```

2. **Verify Network**:
   ```bash
   docker network ls | grep asone4health_network
   ```

3. **Manual Network Creation**:
   ```bash
   docker network create asone4health_network --subnet=172.24.0.0/16
   ```

### Connection Issues

1. **Check Node Health**:
   ```bash
   curl http://admin:admin123@localhost:5984/_up
   curl http://admin:admin123@localhost:5985/_up
   curl http://admin:admin123@localhost:5986/_up
   ```

2. **IP Conflicts**: If you have network conflicts, modify `.env`:
   ```env
   NETWORK_SUBNET=172.25.0.0/16
   NODE0_IP=172.25.0.20
   NODE1_IP=172.25.0.21
   NODE2_IP=172.25.0.22
   CLUSTER_INIT_IP=172.25.0.23
   MANAGER_IP=172.25.0.24
   BACKUP_SERVICE_IP=172.25.0.25
   ```

   Then recreate the network:
   ```bash
   docker-compose down
   docker network rm asone4health_network
   docker network create asone4health_network --subnet=172.25.0.0/16
   docker-compose up -d
   ```

## Security Notes

- Change default passwords in production
- Generate new secrets: `openssl rand -base64 32`
- Use HTTPS in production environments
- Restrict network access appropriately
- Keep `.env` file secure and never commit it

## Inspired by
- https://docs.couchdb.org/en/master/setup/cluster.html
- https://github.com/apache/couchdb-docker/issues/74
- https://github.com/apache/couchdb/issues/2858

