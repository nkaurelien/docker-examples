# CouchDB Manager Service

## Overview

The CouchDB Manager is an integrated Streamlit-based web application that provides a comprehensive interface for managing CouchDB clusters. It's automatically deployed as part of the Docker Compose setup.

## Features

### 📊 Dashboard
- View database statistics across all cluster nodes
- Compare database counts and sizes between source and target
- Monitor cluster health and node status

### 💾 Backup Operations
- Create local backups with full attachment support
- Supports all CouchDB document types including design documents
- Timestamped backup organization
- Progress tracking with real-time updates

### ♻️ Restore Operations
- Restore databases from backup files
- Intelligent attachment handling (data vs stubs)
- Support for both old and new backup formats
- Batch restoration with error handling

### 🔄 Synchronization
- Sync databases between different CouchDB instances
- Source to Target and Target to Source directions
- Selective database synchronization
- Real-time sync progress monitoring

### 🗑️ Safe Delete
- Database deletion with multiple safety confirmations
- Type-to-confirm security measures
- Irreversible operation warnings
- Detailed logging of delete operations

## Access

- **URL**: http://localhost:8501
- **Startup**: Automatic with CouchDB cluster
- **Dependencies**: Waits for all 3 CouchDB nodes to be healthy

## Architecture

```
┌─────────────────────────────────────────────────┐
│                CouchDB Manager                  │
│               (Streamlit UI)                    │
│              172.24.0.24:8501                   │
└─────────────────────────────────────────────────┘
                        │
            ┌───────────┼───────────┐
            │           │           │
    ┌───────────┐ ┌───────────┐ ┌───────────┐
    │ CouchDB-0 │ │ CouchDB-1 │ │ CouchDB-2 │
    │ 172.24.0  │ │ 172.24.0  │ │ 172.24.0  │
    │   .20     │ │   .21     │ │   .22     │
    │  :5984    │ │  :5984    │ │  :5984    │
    └───────────┘ └───────────┘ └───────────┘
            │           │           │
            └───────────┼───────────┘
                        │
            ┌───────────────────────┐
            │       Ofelia          │
            │  (Backup Scheduler)   │
            │   172.24.0.25         │
            │   Daily 2 AM          │
            └───────────────────────┘
```

**Note**: The cluster also includes Ofelia job scheduler for automated backups. See main README.md for backup configuration.

## Configuration

The service automatically loads configuration from environment variables:

```env
SOURCE_COUCHDB_URL=http://admin:password@localhost:5984/
TARGET_COUCHDB_URL=http://remote-user:password@remote:port/
MANAGER_IP=172.24.0.24
```

Default ports:
- Node 0: 5984 (or PORT_BASE+0 if customized)
- Node 1: 5985 (or PORT_BASE+1 if customized)
- Node 2: 5986 (or PORT_BASE+2 if customized)

## Docker Service Configuration

```yaml
couchdb-manager:
  build:
    context: .
    dockerfile_inline: |
      FROM python:3.11-slim
      # ... (see docker-compose.yml for full definition)
  ports:
    - "8501:8501"
  environment:
    - SOURCE_COUCHDB_URL=${SOURCE_COUCHDB_URL}
    - TARGET_COUCHDB_URL=${TARGET_COUCHDB_URL}
  volumes:
    - ./backups:/app/backups
    - ./manage:/app/manage:ro
  depends_on:
    - couchdb-0
    - couchdb-1
    - couchdb-2
```

## Usage Examples

### Basic Workflow

1. **Access the UI**: Navigate to http://localhost:8501
2. **View Dashboard**: Check cluster status and database counts
3. **Configure URLs**: Source and Target are pre-configured from environment
4. **Perform Operations**: Use tabs for Backup, Restore, Sync, or Delete

### Backup Workflow

#### Manual Backups (via UI)

1. Select **Backup** tab
2. Choose source (Source or Target database)
3. Select databases to backup
4. Click **Start Backup**
5. Monitor progress in real-time
6. Find backups in `./backups/` directory

#### Automated Backups (via Ofelia)

The cluster includes Ofelia scheduler for automated backups:

- **Schedule**: Daily at 2:00 AM (configurable)
- **Script**: `/opt/scripts/backup-job.sh`
- **Location**: `/opt/backups/ofelia_backup_TIMESTAMP/`
- **Retention**: 7 days (configurable via BACKUP_RETENTION_DAYS)

To manage automated backups:
```bash
# Start backup scheduler
make backup-service-start

# Check scheduler status
make backup-service-status

# Run immediate backup
make backup-now
```

See README.md "Automated Backups with Ofelia" section for full configuration.

### Restore Workflow

1. Select **Restore** tab
2. Choose target (Source or Target database)
3. Select backup directory
4. Choose databases to restore
5. Configure clean restore option if needed
6. Click **Start Restore**
7. Monitor progress and verify success

## File Structure

```
couchdb-cluster/
├── couchdb_manager.py          # Main Streamlit application
├── requirements.txt            # Python dependencies
├── backups/                   # Backup storage directory
│   └── .gitignore             # Ignore backup files
├── scripts/                   # Automation scripts
│   └── backup-job.sh          # Ofelia backup script
├── manage/                   # Management scripts
│   └── backup_restore_couchdb.sh
├── config/                    # Configuration files
│   ├── ofelia.ini             # Ofelia config (alternative)
│   ├── couchdb0/              # Node 0 config
│   ├── couchdb1/              # Node 1 config
│   └── couchdb2/              # Node 2 config
├── docker-compose.yml        # Service definitions (all services)
├── Makefile                  # Management commands
└── README.md                 # Complete documentation
```

## Development

### Running Locally

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export SOURCE_COUCHDB_URL="http://admin:password@localhost:5984/"
export TARGET_COUCHDB_URL="http://admin:password@remote:5984/"

# Run the application
streamlit run couchdb_manager.py
```

### Debugging

- **Container Logs**: `docker-compose logs couchdb-manager`
- **Health Check**: `docker-compose ps` (should show healthy status)
- **Direct Access**: `docker exec -it couchdb-manager_1 /bin/bash`

## Security Considerations

- Environment variables contain sensitive database credentials
- Backup files may contain sensitive data - secure storage recommended
- Web UI is accessible without authentication - restrict network access in production
- Delete operations are irreversible - use with caution

## Troubleshooting

### Common Issues

1. **Service Won't Start**
   - Check CouchDB nodes are healthy: `docker-compose ps`
   - Verify environment variables are set
   - Check logs: `docker-compose logs couchdb-manager`

2. **Connection Errors**
   - Verify SOURCE_COUCHDB_URL and TARGET_COUCHDB_URL
   - Test direct curl access to CouchDB endpoints
   - Check network connectivity between containers

3. **Backup/Restore Failures**
   - Check available disk space for backups
   - Verify CouchDB authentication credentials
   - Review attachment handling for large files

### Log Analysis

The service provides detailed logging for all operations:

```bash
# Follow logs in real-time
docker-compose logs -f couchdb-manager

# Check specific error messages
docker-compose logs couchdb-manager | grep ERROR
```

## Performance Notes

- Backup operations include full attachment data
- Large databases may take significant time to backup/restore
- Network bandwidth affects sync operations between remote instances
- Resource usage scales with database size and operation complexity