# PostgreSQL with Automated Backups

A production-ready PostgreSQL setup with automated backup system using Ofelia scheduler, pgAdmin web interface, and comprehensive management tools.

## Features

- **PostgreSQL 16 Alpine**: Lightweight, latest stable version
- **Automated Backups**: Scheduled daily backups using Ofelia
- **Manual Backup/Restore**: Easy database export and import
- **pgAdmin 4**: Web-based PostgreSQL administration tool
- **Backup Retention**: Automatic cleanup of old backups
- **Health Checks**: Automatic service monitoring
- **Environment Variables**: Fully configurable via .env file
- **Makefile Commands**: 30+ simple management commands
- **Single or All Databases**: Backup individual or all databases

## Quick Start

### 1. Setup Environment

```bash
# Copy the example environment file
make setup

# Edit .env and customize your settings
nano .env
```

### 2. Start PostgreSQL

```bash
# Start PostgreSQL
make up

# Or use docker-compose directly
docker-compose up -d postgres
```

### 3. Access PostgreSQL

```bash
# Via psql command
make shell-psql

# Via connection string
psql -h localhost -p 5432 -U postgres -d postgres
```

### 4. Optional: Start pgAdmin

```bash
# Start pgAdmin web interface
make pgadmin-start

# Access at http://localhost:5050
# Default credentials in .env file
```

## Configuration

### Environment Variables

Edit `.env` file:

```env
# Project name
COMPOSE_PROJECT_NAME=postgres

# PostgreSQL Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=postgres
POSTGRES_PORT=5432

# pgAdmin Configuration
PGADMIN_EMAIL=admin@example.com
PGADMIN_PASSWORD=admin
PGADMIN_PORT=5050

# Backup Configuration
BACKUP_SCHEDULE=0 2 * * *  # Daily at 2:00 AM
BACKUP_RETENTION_DAYS=7    # Keep backups for 7 days
BACKUP_ALL_DBS=false       # Backup single DB or all DBs
```

### Backup Modes

#### Single Database Backup (`BACKUP_ALL_DBS=false`)
- Uses `pg_dump` to backup only `POSTGRES_DB`
- Faster, smaller backup files
- Best for single-database applications
- File naming: `postgres_dbname_TIMESTAMP.sql.gz`

#### All Databases Backup (`BACKUP_ALL_DBS=true`)
- Uses `pg_dumpall` to backup all PostgreSQL databases
- Includes users, roles, and permissions
- Best for complete PostgreSQL instance backup
- File naming: `postgres_all_TIMESTAMP.sql.gz`

### Backup Schedule

The backup schedule uses cron format: `minute hour day month weekday`

Examples:
- `0 2 * * *` - Daily at 2:00 AM (default)
- `0 */6 * * *` - Every 6 hours
- `0 0 * * 0` - Weekly on Sunday at midnight
- `0 3 * * 1-5` - Weekdays at 3:00 AM

## Backup Management

### Automated Backups (Ofelia)

Start the Ofelia scheduler for automated backups:

```bash
# Start backup scheduler
make backup-service-start

# Check scheduler status
make backup-service-status

# Stop backup scheduler
make backup-service-stop
```

Ofelia will automatically:
- Run backups according to the schedule in `.env`
- Create timestamped compressed backups
- Maintain a daily schema-only backup
- Clean up backups older than retention period
- Prevent overlapping backup jobs

### Manual Backups

```bash
# Create backup immediately
make backup-now

# List all backups
make backup-list

# Restore from latest backup
make backup-restore

# Restore from specific backup
BACKUP_FILE=/backups/postgres_mydb_2024-11-13_120000.sql.gz make backup-restore
```

### Backup Files

Backups are stored in `./backups/`:

**Single Database Mode:**
- `postgres_dbname_YYYY-MM-DD_HHMMSS.sql.gz` - Full compressed backup
- `postgres_dbname_schema_YYYY-MM-DD.sql` - Schema-only backup (daily)
- `postgres_dbname_latest.sql.gz` - Symlink to latest backup

**All Databases Mode:**
- `postgres_all_YYYY-MM-DD_HHMMSS.sql.gz` - Full compressed backup
- `postgres_all_schema_YYYY-MM-DD.sql` - Schema-only backup (daily)
- `postgres_all_latest.sql.gz` - Symlink to latest backup

## Common Commands

### Service Management

```bash
# Start services
make up

# Stop services
make down

# Restart services
make restart

# View status
make status

# View logs
make logs           # All services
make logs-db        # PostgreSQL only
make logs-pgadmin   # pgAdmin only
make logs-ofelia    # Backup scheduler only
```

### Database Operations

```bash
# Open psql shell
make shell-psql

# Open container shell
make shell-db

# Export database
make export

# Import database
make import

# Check health
make health
```

### pgAdmin Operations

```bash
# Start pgAdmin
make pgadmin-start

# Stop pgAdmin
make pgadmin-stop
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   PostgreSQL Stack                       │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────┐      ┌──────────────┐                │
│  │  PostgreSQL  │      │   pgAdmin    │                │
│  │  Port: 5432  │      │  Port: 5050  │                │
│  │ (Alpine 16)  │      │  (optional)  │                │
│  └───────┬──────┘      └──────────────┘                │
│          │                                                │
│          │                                                │
│    ┌─────┴──────┐                                        │
│    │            │                                        │
│ ┌──▼────┐  ┌───▼─────┐                                 │
│ │Export │  │ Import  │                                 │
│ │(manual│  │(manual) │                                 │
│ └───┬───┘  └────┬────┘                                 │
│     │           │                                        │
│     └─────┬─────┘                                        │
│           │                                              │
│     ┌─────▼──────┐                                      │
│     │   Ofelia   │                                      │
│     │ Scheduler  │                                      │
│     │(automated) │                                      │
│     └────────────┘                                      │
│                                                           │
│  Persistent Volumes:                                     │
│    - postgres_data    (Database data)                    │
│    - pgadmin_data     (pgAdmin settings)                 │
│    - ./backups        (Backup files)                     │
│    - ./init           (Init scripts)                     │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

## Backup Scripts

### backup-export.sh

Located in `./scripts/backup-export.sh`, this script:

- Waits for PostgreSQL to be ready using `pg_isready`
- Supports two modes:
  - Single database: Uses `pg_dump` for specific database
  - All databases: Uses `pg_dumpall` for complete instance
- Creates full compressed backup with gzip
- Creates daily schema-only backup
- Maintains symlink to latest backup
- Cleans up old backups based on retention policy
- Provides detailed logging and error handling

### backup-import.sh

Located in `./scripts/backup-import.sh`, this script:

- Waits for PostgreSQL to be ready
- Identifies backup file (latest or specified)
- Creates safety backup before importing
- Imports backup (handles both compressed and uncompressed)
- Supports restoring single database or all databases
- Verifies import success with table/database count
- Provides detailed logging

## Docker Compose Services

### postgres

- Image: `postgres:16-alpine`
- Persistent volume: `postgres_data`
- Health checks enabled
- Automatic restart
- Configurable port (default: 5432)

### pgAdmin (Optional, Profile: tools)

- Image: `dpage/pgadmin4:latest`
- Depends on: `postgres` (healthy)
- Persistent volume: `pgadmin_data`
- Port: 5050 (configurable)
- Start with: `make pgadmin-start`

### dbexport

- Image: `postgres:16-alpine`
- Runs: `backup-export.sh`
- One-time execution (restart: no)
- Can be triggered via Ofelia or manually
- Profile: `manual`

### dbimport

- Image: `postgres:16-alpine`
- Runs: `backup-import.sh`
- One-time execution (restart: no)
- Manual use only
- Profile: `manual`

### ofelia

- Image: `mcuadros/ofelia:latest`
- Mode: Docker labels (daemon --docker)
- Profile: `backup` (optional service)
- Automatic restart
- Schedules dbexport jobs via `job-run`

## Production Considerations

### Security

1. **Change Default Passwords**: Update all passwords in `.env`
2. **Don't Expose PostgreSQL**: Don't expose port 5432 to internet
3. **Use SSL/TLS**: Configure PostgreSQL SSL in production
4. **Firewall**: Restrict access to PostgreSQL port
5. **Strong Authentication**: Use md5 or scram-sha-256 authentication

### Backup Strategy

1. **Regular Backups**: Enable Ofelia for automated backups
2. **Off-site Storage**: Copy backups to S3, NFS, or external storage
3. **Test Restores**: Regularly test backup restoration
4. **Monitor Disk Space**: Watch backup directory size
5. **Retention Policy**: Adjust `BACKUP_RETENTION_DAYS` based on needs
6. **All Databases Mode**: Use `BACKUP_ALL_DBS=true` for complete protection

### Performance

1. **Connection Pooling**: Use PgBouncer for connection pooling
2. **Tuning**: Adjust PostgreSQL configuration (shared_buffers, work_mem, etc.)
3. **Indexes**: Create proper indexes for query optimization
4. **Vacuum**: Configure autovacuum settings
5. **Monitoring**: Use pg_stat_statements for query analysis

### High Availability

For production HA setup, consider:

- PostgreSQL replication (streaming replication)
- Connection pooling with PgBouncer or Pgpool-II
- Load balancing with HAProxy
- Failover automation with Patroni or repmgr

## Initialization Scripts

Place SQL scripts in `./init/` directory. PostgreSQL will execute them on first startup:

```bash
mkdir -p init
echo "CREATE DATABASE myapp;" > init/01-create-db.sql
echo "CREATE USER myapp WITH PASSWORD 'myapp';" > init/02-create-user.sql
echo "GRANT ALL PRIVILEGES ON DATABASE myapp TO myapp;" > init/03-grant.sql
```

Scripts are executed in alphabetical order, only on first container startup.

## Troubleshooting

### PostgreSQL Won't Start

```bash
# Check logs
make logs-db

# Verify configuration
docker-compose config

# Check health
make health

# Check disk space
df -h
```

### Backup Fails

```bash
# Check Ofelia logs
make logs-ofelia

# Test manual backup
make backup-now

# Verify PostgreSQL is running
make status

# Check disk space
df -h ./backups
```

### Import Fails

```bash
# List available backups
make backup-list

# Try importing specific backup
BACKUP_FILE=/backups/postgres_mydb_2024-11-13.sql.gz make backup-restore

# Check PostgreSQL logs
make logs-db
```

### Can't Connect to PostgreSQL

```bash
# Check if service is running
make status

# Test connection from container
docker-compose exec postgres pg_isready -U postgres

# Check if port is exposed
docker-compose ps

# Test from host
psql -h localhost -p 5432 -U postgres -d postgres
```

### Permission Errors

```bash
# Fix backup directory permissions
chmod -R 755 ./backups

# Fix script permissions
chmod +x ./scripts/*.sh
```

## Directory Structure

```
postgres/
├── docker-compose.yml                # Main Docker Compose configuration
├── .env                              # Environment variables (create from .env.example)
├── .env.example                      # Example environment configuration
├── .gitignore                        # Git ignore rules
├── Makefile                          # Management commands
├── README.md                         # This file
├── docker_postgres_backup_restore_guide.md  # Detailed backup guide
├── scripts/
│   ├── backup-export.sh              # Database export script
│   └── backup-import.sh              # Database import script
├── backups/                          # Database backups (auto-created)
└── init/                             # Initialization SQL scripts (optional)
```

## Makefile Commands Reference

```bash
make help                  # Show all available commands

# Setup
make setup                 # Create .env from .env.example

# Service Management
make up                    # Start PostgreSQL
make down                  # Stop services
make restart               # Restart services
make status                # Show status
make logs                  # Show logs

# Database Access
make shell-psql            # Open psql terminal
make shell-db              # Open container shell

# Backup Management
make backup-now            # Create backup immediately
make backup-list           # List available backups
make backup-restore        # Restore from latest backup
make backup-service-start  # Start automated backups
make backup-service-stop   # Stop automated backups
make backup-service-status # Check backup scheduler

# Tools
make pgadmin-start         # Start pgAdmin
make pgadmin-stop          # Stop pgAdmin

# Maintenance
make health                # Check services health
make clean                 # Remove all data (⚠️  DESTRUCTIVE)
```

## Additional Resources

- **Backup Guide**: See [docker_postgres_backup_restore_guide.md](docker_postgres_backup_restore_guide.md) for detailed backup examples
- **PostgreSQL Docs**: https://www.postgresql.org/docs/
- **pgAdmin Docs**: https://www.pgadmin.org/docs/
- **Ofelia**: https://github.com/mcuadros/ofelia
- **Docker Compose**: https://docs.docker.com/compose/

## Migration from Existing PostgreSQL

To migrate data from an existing PostgreSQL instance:

1. Backup your existing database:
   ```bash
   pg_dump -h old-host -U user -d database > backup.sql
   ```

2. Copy backup to backups directory:
   ```bash
   cp backup.sql ./backups/
   ```

3. Start new PostgreSQL instance:
   ```bash
   make up
   ```

4. Import backup:
   ```bash
   BACKUP_FILE=/backups/backup.sql make import
   ```

## License

This is a Docker Compose configuration example. PostgreSQL and other components have their own licenses.
