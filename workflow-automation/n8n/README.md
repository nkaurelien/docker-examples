# n8n Workflow Automation

A production-ready n8n setup with PostgreSQL database backend, featuring automated setup, backup capabilities, and comprehensive management tools.

## Features

- 🚀 **Easy Setup**: One-command deployment with sensible defaults
- 🗄️ **PostgreSQL Backend**: Persistent workflow storage with dedicated database
- 🔐 **Security Built-in**: Basic auth, encryption keys, secure defaults
- 💾 **Backup System**: Easy workflow and credential backup
- 🛠️ **Makefile Management**: Simplified operations with make commands
- 📊 **Health Monitoring**: Built-in health checks and status commands
- 🔄 **Auto-restart**: Services restart automatically on failure

## Quick Start

### 1. Setup Environment

```bash
# Create .env from example
make setup

# Generate encryption key
make generate-key

# Edit .env with your settings
nano .env
```

**Required settings in `.env`:**
- `POSTGRES_PASSWORD` - PostgreSQL root password
- `POSTGRES_NON_ROOT_PASSWORD` - n8n database user password
- `N8N_BASIC_AUTH_PASSWORD` - n8n UI password
- `N8N_ENCRYPTION_KEY` - Generate with `make generate-key`

### 2. Start Services

```bash
# Start n8n and PostgreSQL
make up

# Check status
make status

# View logs
make logs
```

### 3. Access n8n

- **URL**: http://localhost:5678
- **Username**: admin (configurable in .env)
- **Password**: Set in .env as `N8N_BASIC_AUTH_PASSWORD`

## Architecture

```
┌─────────────────────────────────────┐
│          n8n Container              │
│     Workflow Automation Engine      │
│         Port: 5678                  │
└─────────────┬───────────────────────┘
              │
              │ PostgreSQL Connection
              │
┌─────────────▼───────────────────────┐
│      PostgreSQL Container           │
│      Database: n8n                  │
│      User: n8n (non-root)           │
└─────────────────────────────────────┘
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `N8N_HOST` | n8n hostname | localhost |
| `N8N_PORT` | External port | 5678 |
| `N8N_PROTOCOL` | Protocol (http/https) | http |
| `N8N_BASIC_AUTH_ACTIVE` | Enable basic auth | true |
| `N8N_BASIC_AUTH_USER` | Username | admin |
| `N8N_BASIC_AUTH_PASSWORD` | Password | (required) |
| `N8N_ENCRYPTION_KEY` | Encryption key | (required) |
| `POSTGRES_DB` | Database name | n8n |
| `POSTGRES_USER` | Root user | postgres |
| `POSTGRES_PASSWORD` | Root password | (required) |
| `POSTGRES_NON_ROOT_USER` | n8n DB user | n8n |
| `POSTGRES_NON_ROOT_PASSWORD` | n8n DB password | (required) |
| `TIMEZONE` | Timezone | UTC |

### Webhook Configuration

For external webhooks, update these in `.env`:

```env
N8N_HOST=your-domain.com
N8N_PROTOCOL=https
WEBHOOK_URL=https://your-domain.com
```

## Makefile Commands

Run `make help` to see all available commands:

### Quick Start
```bash
make setup        # Create .env from example
make up           # Start services
make status       # Show status
make logs         # View logs
```

### Service Management
```bash
make up           # Start all services
make down         # Stop and remove services
make restart      # Restart services
make stop         # Stop services (keep containers)
make start        # Start stopped services
```

### Logs & Debugging
```bash
make logs         # Follow all logs
make logs-n8n     # Follow n8n logs only
make logs-db      # Follow PostgreSQL logs only
make shell        # Open shell in n8n container
make shell-db     # Open PostgreSQL shell
make health       # Check service health
```

### Data Management
```bash
make backup       # Backup workflows and credentials
make list-workflows  # List workflow files
make clean        # Remove all data (⚠️ DESTRUCTIVE)
```

### Security
```bash
make generate-key # Generate new encryption key
```

## Data Persistence

### Volumes

- `postgres_data` - PostgreSQL database files
- `n8n_data` - n8n internal data
- `./workflows` - Workflow JSON files (backed up)
- `./credentials` - Encrypted credentials (backed up)

### Backups

Create backups of workflows and credentials:

```bash
# Create backup
make backup

# Backups are stored in ./backups/n8n-backup-TIMESTAMP/
ls -la ./backups/
```

**What's backed up:**
- All workflow JSON files
- Encrypted credential files
- Timestamps for easy identification

**What's NOT backed up:**
- PostgreSQL database (use pg_dump for full database backup)
- Execution history

## Workflows

### Creating Workflows

1. Access n8n UI at http://localhost:5678
2. Create workflows using the visual editor
3. Workflows are auto-saved to the database
4. Export workflows for backup: `make backup`

### Workflow Files

Workflows can be exported to `./workflows/` directory for:
- Version control
- Sharing with team
- Migration between instances

## Security Considerations

### Production Deployment

**Before deploying to production:**

1. **Change Default Passwords**
   ```bash
   # Edit .env and set strong passwords for:
   # - POSTGRES_PASSWORD
   # - POSTGRES_NON_ROOT_PASSWORD
   # - N8N_BASIC_AUTH_PASSWORD
   ```

2. **Generate Encryption Key**
   ```bash
   make generate-key
   # Add output to .env as N8N_ENCRYPTION_KEY
   ```

3. **Use HTTPS**
   ```env
   N8N_PROTOCOL=https
   WEBHOOK_URL=https://your-domain.com
   ```

4. **Restrict Network Access**
   - Use reverse proxy (nginx/traefik)
   - Configure firewall rules
   - Use VPN for admin access

5. **Regular Backups**
   ```bash
   # Setup cron job for daily backups
   0 2 * * * cd /path/to/n8n && make backup
   ```

### Security Best Practices

- ✅ Keep `.env` file secure (never commit to git)
- ✅ Use strong, unique passwords
- ✅ Enable basic authentication
- ✅ Use HTTPS in production
- ✅ Regular security updates: `docker-compose pull && make restart`
- ✅ Regular backups
- ✅ Monitor execution logs
- ✅ Limit webhook exposure

## Troubleshooting

### n8n Won't Start

1. **Check PostgreSQL is healthy:**
   ```bash
   make logs-db
   docker-compose ps postgres
   ```

2. **Verify environment variables:**
   ```bash
   cat .env
   ```

3. **Check n8n logs:**
   ```bash
   make logs-n8n
   ```

### Database Connection Errors

1. **Verify database credentials:**
   ```bash
   make shell-db
   # Check if n8n user exists
   \du
   ```

2. **Re-initialize database:**
   ```bash
   make down
   make up
   ```

### Can't Access n8n UI

1. **Check if n8n is running:**
   ```bash
   make health
   ```

2. **Verify port is not in use:**
   ```bash
   lsof -i :5678
   ```

3. **Check firewall settings**

### Backup Restoration

To restore from backup:

```bash
# Stop services
make down

# Copy backup files to ./workflows and ./credentials
cp -r ./backups/n8n-backup-TIMESTAMP/workflows ./
cp -r ./backups/n8n-backup-TIMESTAMP/credentials ./

# Start services
make up
```

## Performance Tuning

### For High-Volume Workflows

1. **Increase execution data pruning frequency**
   ```yaml
   # In docker-compose.yml
   EXECUTIONS_DATA_MAX_AGE: 24  # Keep only 24 hours
   ```

2. **Adjust PostgreSQL settings**
   ```yaml
   # Add to postgres service
   command:
     - postgres
     - -c
     - shared_buffers=256MB
     - -c
     - max_connections=200
   ```

3. **Scale horizontally**
   - Use n8n in queue mode with Redis
   - Deploy multiple worker instances

## Upgrading n8n

```bash
# Pull latest image
docker-compose pull n8n

# Recreate container
make restart

# Check version
make logs-n8n | grep "n8n ready"
```

## Integration Examples

### With Reverse Proxy

Example nginx configuration:

```nginx
server {
    listen 80;
    server_name n8n.example.com;

    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### With Docker Compose Networks

Connect n8n to other services:

```yaml
networks:
  n8n_network:
    external: true
    name: your_shared_network
```

## Resources

- **Official Documentation**: https://docs.n8n.io/
- **Community Forum**: https://community.n8n.io/
- **Workflow Templates**: https://n8n.io/workflows
- **GitHub**: https://github.com/n8n-io/n8n

## Support

For issues or questions:
1. Check logs: `make logs`
2. Review troubleshooting section
3. Consult n8n documentation
4. Visit community forum

## License

This Docker Compose setup is provided as-is. n8n is licensed under the Sustainable Use License.
