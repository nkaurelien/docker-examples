# WordPress with MySQL and Automated Backups

A complete WordPress development environment with MySQL database, PHPMyAdmin, and automated backup system using Ofelia scheduler.

## Features

- **WordPress**: Latest version with persistent storage
- **MySQL 5.7**: Reliable database with health checks
- **PHPMyAdmin**: Web-based MySQL administration
- **Automated Backups**: Scheduled daily backups using Ofelia
- **Manual Backup/Restore**: Easy database export and import
- **Backup Retention**: Automatic cleanup of old backups
- **Environment Variables**: Configurable via .env file
- **Makefile Commands**: Simple management commands

## Quick Start

### 1. Setup Environment

```bash
# Copy the example environment file
make setup

# Edit .env and customize your settings
nano .env
```

### 2. Start Services

```bash
# Start WordPress, MySQL, and PHPMyAdmin
make up

# Or use docker-compose directly
docker-compose up -d
```

### 3. Access Services

- **WordPress**: http://localhost:8000
- **PHPMyAdmin**: http://localhost:8080
  - Server: `db`
  - Username: `root`
  - Password: (from .env `MYSQL_ROOT_PASSWORD`)

### 4. Complete WordPress Installation

1. Open http://localhost:8000
2. Follow the WordPress installation wizard
3. Use the database credentials from your `.env` file

## Configuration

### Environment Variables

Edit `.env` file:

```env
# Project name
COMPOSE_PROJECT_NAME=wordpress

# MySQL Configuration
MYSQL_ROOT_PASSWORD=secret
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD=wordpress

# Ports
WORDPRESS_PORT=8000
PHPMYADMIN_PORT=8080

# Backup Configuration
BACKUP_SCHEDULE=0 2 * * *  # Daily at 2:00 AM
BACKUP_RETENTION_DAYS=7    # Keep backups for 7 days
```

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
BACKUP_FILE=/dumps/wordpress_2024-11-13_120000.sql.gz make backup-restore
```

### Backup Files

Backups are stored in `./database/dumps/`:

- `wordpress_YYYY-MM-DD_HHMMSS.sql.gz` - Full compressed backup
- `wordpress_schema_YYYY-MM-DD.sql` - Schema-only backup (daily)
- `wordpress_latest.sql.gz` - Symlink to latest backup

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
make logs-db        # MySQL only
make logs-wp        # WordPress only
make logs-ofelia    # Backup scheduler only
```

### Database Operations

```bash
# Open MySQL shell
make shell-db

# Export database
make export

# Import database
make import

# Check health
make health
```

### Development

```bash
# Open WordPress container shell
make shell-wp

# Access PHPMyAdmin
# http://localhost:8080
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    WordPress Stack                       │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────┐      ┌──────────────┐                │
│  │  WordPress   │      │  PHPMyAdmin  │                │
│  │  Port: 8000  │      │  Port: 8080  │                │
│  └───────┬──────┘      └───────┬──────┘                │
│          │                     │                         │
│          └──────────┬──────────┘                         │
│                     │                                     │
│              ┌──────▼──────┐                            │
│              │   MySQL 5.7  │                            │
│              │   Port: 3306 │                            │
│              │  (internal)  │                            │
│              └──────┬───────┘                            │
│                     │                                     │
│          ┌──────────┴──────────┐                         │
│          │                     │                         │
│    ┌─────▼──────┐      ┌──────▼─────┐                  │
│    │  dbexport  │      │  dbimport  │                  │
│    │  (manual)  │      │  (manual)  │                  │
│    └─────┬──────┘      └──────┬─────┘                  │
│          │                     │                         │
│          └──────────┬──────────┘                         │
│                     │                                     │
│              ┌──────▼──────┐                            │
│              │   Ofelia    │                            │
│              │  Scheduler  │                            │
│              │ (automated) │                            │
│              └─────────────┘                            │
│                                                           │
│  Persistent Volumes:                                     │
│    - db_data          (MySQL data)                       │
│    - ./wordpress      (WordPress files)                  │
│    - ./database/dumps (Backups)                          │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

## Backup Scripts

### backup-export.sh

Located in `./scripts/backup-export.sh`, this script:

- Waits for MySQL to be ready
- Creates full compressed database backup
- Creates daily schema-only backup
- Maintains symlink to latest backup
- Cleans up old backups based on retention policy
- Provides detailed logging and error handling

### backup-import.sh

Located in `./scripts/backup-import.sh`, this script:

- Waits for MySQL to be ready
- Identifies backup file (latest or specified)
- Creates safety backup before importing
- Imports backup (handles both compressed and uncompressed)
- Verifies import success
- Provides detailed logging

## Docker Compose Services

### db (MySQL)

- Image: `mysql:5.7`
- Persistent volume: `db_data`
- Health checks enabled
- Automatic restart

### wordpress

- Image: `wordpress:latest`
- Depends on: `db` (healthy)
- Persistent volume: `./wordpress`
- Port: 8000 (configurable)
- Automatic restart

### phpmyadmin

- Image: `phpmyadmin`
- Depends on: `db` (healthy)
- Port: 8080 (configurable)
- Auto-login as root

### dbexport

- Image: `mysql:5.7`
- Runs: `backup-export.sh`
- One-time execution (restart: no)
- Can be triggered via Ofelia or manually

### dbimport

- Image: `mysql:5.7`
- Runs: `backup-import.sh`
- One-time execution (restart: no)
- Manual use only

### ofelia

- Image: `mcuadros/ofelia:latest`
- Mode: Docker labels (daemon --docker)
- Profile: `backup` (optional service)
- Automatic restart
- Schedules dbexport jobs

## Production Considerations

### Security

1. **Change Default Passwords**: Update all passwords in `.env`
2. **Don't Expose MySQL**: MySQL port 3306 is not exposed externally
3. **Use HTTPS**: Put WordPress behind a reverse proxy with SSL
4. **Firewall**: Restrict access to ports 8000 and 8080
5. **File Permissions**: Ensure proper ownership of `./wordpress` directory

### Backup Strategy

1. **Regular Backups**: Enable Ofelia for automated backups
2. **Off-site Storage**: Copy backups to external storage
3. **Test Restores**: Regularly test backup restoration
4. **Monitor Disk Space**: Watch backup directory size
5. **Retention Policy**: Adjust `BACKUP_RETENTION_DAYS` based on needs

### Performance

1. **MySQL Tuning**: Adjust MySQL configuration for your workload
2. **WordPress Caching**: Install caching plugins (W3 Total Cache, WP Super Cache)
3. **PHP Memory**: Increase WordPress memory limit if needed
4. **Database Optimization**: Regular database optimization in PHPMyAdmin

### Reverse Proxy (Production)

Example nginx configuration:

```nginx
server {
    listen 443 ssl;
    server_name yourdomain.com;

    # SSL configuration
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Troubleshooting

### WordPress Installation Fails

```bash
# Check MySQL is running and healthy
make status

# Check WordPress can connect to database
make logs-wp

# Verify database credentials in .env
```

### Can't Access Services

```bash
# Check if ports are already in use
lsof -i :8000
lsof -i :8080

# Change ports in .env if needed
WORDPRESS_PORT=8001
PHPMYADMIN_PORT=8081
```

### Backup Fails

```bash
# Check Ofelia logs
make logs-ofelia

# Test manual backup
make backup-now

# Verify MySQL credentials
make shell-db

# Check disk space
df -h
```

### Import Fails

```bash
# List available backups
make backup-list

# Try importing specific backup
BACKUP_FILE=/dumps/wordpress_2024-11-13.sql.gz make backup-restore

# Check MySQL logs
make logs-db
```

### Permission Errors

```bash
# Fix WordPress directory permissions
sudo chown -R 33:33 ./wordpress

# Fix backup directory permissions
sudo chmod -R 755 ./database/dumps
```

## Directory Structure

```
mysql-wordpress/
├── docker-compose.yml      # Main Docker Compose configuration
├── .env                    # Environment variables (create from .env.example)
├── .env.example            # Example environment configuration
├── .gitignore              # Git ignore rules
├── Makefile                # Management commands
├── README.md               # This file
├── scripts/
│   ├── backup-export.sh    # Database export script
│   └── backup-import.sh    # Database import script
├── wordpress/              # WordPress files (created on first run)
└── database/
    └── dumps/              # Database backups
```

## Makefile Commands Reference

```bash
make help                  # Show all available commands

# Setup
make setup                 # Create .env from .env.example

# Service Management
make up                    # Start services
make down                  # Stop services
make restart               # Restart services
make status                # Show status
make logs                  # Show logs

# Backup Management
make backup-now            # Create backup immediately
make backup-list           # List available backups
make backup-restore        # Restore from latest backup
make backup-service-start  # Start automated backups
make backup-service-stop   # Stop automated backups
make backup-service-status # Check backup scheduler

# Database Operations
make shell-db              # Open MySQL shell
make export                # Export database
make import                # Import database
make health                # Check services health

# Development
make shell-wp              # Open WordPress shell

# Cleanup
make clean                 # Remove all data (⚠️  DESTRUCTIVE)
```

## Resources

- **WordPress**: https://wordpress.org
- **MySQL**: https://dev.mysql.com/doc/
- **PHPMyAdmin**: https://www.phpmyadmin.net
- **Ofelia**: https://github.com/mcuadros/ofelia
- **Docker Compose**: https://docs.docker.com/compose/

## License

This is a Docker Compose example configuration. Individual components have their own licenses.
