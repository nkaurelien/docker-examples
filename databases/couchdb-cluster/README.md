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
   ```bash
   # Create network if not exists
   docker network create asone4health_network --subnet=172.19.0.0/16
   
   # Start cluster
   docker-compose up -d
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
NETWORK_SUBNET=172.19.0.0/16
NODE0_IP=172.19.0.20
NODE1_IP=172.19.0.21
NODE2_IP=172.19.0.22
CLUSTER_INIT_IP=172.19.0.23
```

### Port Mapping

- **Node 0**: `PORT_BASE+0` (default: 5984)
- **Node 1**: `PORT_BASE+1` (default: 5985)
- **Node 2**: `PORT_BASE+2` (default: 5986)

## Management UI

The included `couchdb_manager.py` provides a web interface for:

- **Dashboard**: View database statistics across nodes
- **Backup**: Create local backups with full attachment support
- **Restore**: Restore databases from backup files
- **Sync**: Synchronize databases between instances
- **Delete**: Safely remove databases with confirmations

### Prerequisites for Management UI

```bash
pip install streamlit requests python-dotenv pandas
```

### Running Management UI

```bash
streamlit run couchdb_manager.py
```

Access at: http://localhost:8501

## Cluster Architecture

```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│    CouchDB Node 0   │    │    CouchDB Node 1   │    │    CouchDB Node 2   │
│   (Coordinator)     │    │                     │    │                     │
│  172.19.0.20:5984   │    │  172.19.0.21:5985   │    │  172.19.0.22:5986   │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
           │                           │                           │
           └───────────────────────────┼───────────────────────────┘
                                      │
                          ┌─────────────────────┐
                          │   Cluster Init      │
                          │  172.19.0.23        │
                          │  (Auto-setup)       │
                          └─────────────────────┘
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
   docker network create asone4health_network --subnet=172.19.0.0/16
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
   NETWORK_SUBNET=172.20.0.0/16
   NODE0_IP=172.20.0.20
   NODE1_IP=172.20.0.21
   NODE2_IP=172.20.0.22
   CLUSTER_INIT_IP=172.20.0.23
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

