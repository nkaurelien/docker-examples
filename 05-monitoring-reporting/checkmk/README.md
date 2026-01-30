# Checkmk - IT Infrastructure Monitoring

Checkmk is a comprehensive IT monitoring solution that enables you to monitor your entire IT infrastructure: servers, applications, networks, cloud environments, containers, storage, databases, and more.

## Features

- **Agent-based & Agentless**: Monitor with agents or SNMP/API
- **Auto-discovery**: Automatic service and host discovery
- **2000+ Check Plugins**: Out-of-the-box monitoring for most systems
- **Alerting**: Flexible notification rules (email, Slack, PagerDuty, etc.)
- **Dashboards**: Customizable visualization
- **Distributed Monitoring**: Scale across multiple sites
- **Business Intelligence**: SLA reporting and BI aggregations
- **REST API**: Full automation capabilities
- **LDAP/SSO**: Enterprise authentication integration

## Editions

| Edition | Description |
|---------|-------------|
| **Raw** | Open source, full monitoring capabilities |
| **Enterprise** | Advanced features, support included |
| **Cloud** | SaaS version |
| **MSP** | Multi-tenant for service providers |

## Quick Start

```bash
cd 05-monitoring-reporting/checkmk
cp .env.example .env
# Edit .env to set CMK_PASSWORD
docker compose up -d
```

Access Checkmk at: http://localhost:8080/cmk/

**Credentials:**
- Username: `cmkadmin`
- Password: Your configured `CMK_PASSWORD`

## Ports

| Port | Description |
|------|-------------|
| 5000 | Web UI (mapped to 8080) |
| 8000 | Agent receiver |
| 6557 | Livestatus (if enabled) |

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CMK_PASSWORD` | `checkmk` | Admin password |
| `CMK_SITE_ID` | `cmk` | Site identifier |
| `TZ` | `Europe/Paris` | Timezone |
| `CMK_LIVESTATUS_TCP` | - | Enable Livestatus TCP |
| `MAIL_RELAY_HOST` | - | SMTP server for notifications |

### Custom Site ID

```yaml
environment:
  - CMK_SITE_ID=mysite
```

Access URL becomes: `http://localhost:8080/mysite/`

### Enable Livestatus TCP

For distributed monitoring or external tools:

```yaml
environment:
  - CMK_LIVESTATUS_TCP=on
ports:
  - "6557:6557"
```

### Email Notifications

```yaml
environment:
  - MAIL_RELAY_HOST=smtp.example.com
```

## Installing Agents

### Linux Agent

```bash
# Download agent from Checkmk
wget http://checkmk-server:8080/cmk/check_mk/agents/check-mk-agent_2.4.0-1_all.deb

# Install (Debian/Ubuntu)
sudo dpkg -i check-mk-agent_*.deb

# Or for RHEL/CentOS
sudo rpm -i check-mk-agent-*.rpm
```

### Windows Agent

1. Download from: `http://checkmk-server:8080/cmk/check_mk/agents/`
2. Run `check_mk_agent.msi`
3. Configure agent controller

### Docker Agent

Monitor Docker hosts:

```bash
# Install agent on Docker host
curl -sL http://checkmk-server:8080/cmk/check_mk/agents/check-mk-agent_2.4.0-1_all.deb -o agent.deb
sudo dpkg -i agent.deb

# Register with agent controller
sudo cmk-agent-ctl register \
  --hostname $(hostname) \
  --server checkmk-server \
  --site cmk \
  --user cmkadmin \
  --password 'yourpassword'
```

### SNMP Devices

For network devices, configure SNMP in Checkmk:
1. Setup > Hosts > Add host
2. Select "SNMP" as monitoring agent
3. Configure SNMP credentials

## Adding Hosts

### Via Web UI

1. Setup > Hosts > Add host
2. Enter hostname and IP address
3. Configure monitoring agent type
4. Run service discovery
5. Activate changes

### Via REST API

```bash
# Create host
curl -X POST \
  "http://localhost:8080/cmk/check_mk/api/1.0/domain-types/host_config/collections/all" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "host_name": "myserver",
    "folder": "/",
    "attributes": {
      "ipaddress": "192.168.1.100"
    }
  }'

# Discover services
curl -X POST \
  "http://localhost:8080/cmk/check_mk/api/1.0/domain-types/service_discovery_run/actions/start/invoke" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"host_name": "myserver", "mode": "tabula_rasa"}'

# Activate changes
curl -X POST \
  "http://localhost:8080/cmk/check_mk/api/1.0/domain-types/activation_run/actions/activate-changes/invoke" \
  -H "Authorization: Bearer $API_TOKEN"
```

## Notification Rules

### Slack Integration

1. Setup > Events > Notifications
2. Add rule > Select "Slack"
3. Configure webhook URL
4. Define conditions (hosts, services, states)

### Email Setup

1. Ensure `MAIL_RELAY_HOST` is configured
2. Setup > Events > Notifications
3. Add rule > Select "HTML Email"
4. Configure recipients

## CLI Access

```bash
# Access container shell as site user
docker exec -it -u cmk checkmk bash

# Checkmk commands
cmk -I myhost           # Inventory scan
cmk -R                  # Reload configuration
cmk -O                  # Restart monitoring core
cmk --list-hosts        # List all hosts
cmk --list-checks       # List available checks

# OMD commands
omd status              # Show site status
omd restart             # Restart all services
omd backup /tmp/backup  # Create backup
```

## Backup & Restore

### Backup

```bash
# Using omd
docker exec -it checkmk omd backup /omd/sites/cmk/backup.tar.gz
docker cp checkmk:/omd/sites/cmk/backup.tar.gz ./

# Or backup volume
docker run --rm \
  -v checkmk-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/checkmk-backup.tar.gz -C /data .
```

### Restore

```bash
# Using omd
docker cp backup.tar.gz checkmk:/tmp/
docker exec -it checkmk omd restore /tmp/backup.tar.gz
```

## Distributed Monitoring

### Central Site

```yaml
environment:
  - CMK_SITE_ID=central
  - CMK_LIVESTATUS_TCP=on
ports:
  - "6557:6557"
```

### Remote Site

1. Install Checkmk on remote server
2. In Central: Setup > Distributed Monitoring > Add connection
3. Configure Livestatus connection
4. Replicate configuration

## Troubleshooting

### View Logs

```bash
# Container logs
docker logs -f checkmk

# Site logs
docker exec -it checkmk tail -f /omd/sites/cmk/var/log/cmc.log
docker exec -it checkmk tail -f /omd/sites/cmk/var/log/web.log
```

### Common Issues

**Cannot access web UI**
```bash
# Check if site is running
docker exec -it checkmk omd status

# Restart site
docker exec -it checkmk omd restart
```

**Agent not connecting**
```bash
# Test agent locally
docker exec -it checkmk check_mk_agent

# Check agent registration
sudo cmk-agent-ctl status
```

**Service discovery not working**
```bash
# Manual discovery
docker exec -it -u cmk checkmk cmk -I hostname

# Check for errors
docker exec -it -u cmk checkmk cmk -D hostname
```

## Performance Tuning

### For Large Environments

```yaml
tmpfs:
  - /opt/omd/sites/cmk/tmp:uid=1000,gid=1000,size=2G
environment:
  # Increase helper processes
  - CMK_HELPERS=10
```

### Resource Recommendations

| Hosts | RAM | CPU |
|-------|-----|-----|
| < 100 | 2 GB | 2 cores |
| 100-500 | 4 GB | 4 cores |
| 500-2000 | 8 GB | 8 cores |
| > 2000 | 16+ GB | 16+ cores |

## Documentation

- [Official Documentation](https://docs.checkmk.com/latest/en/)
- [Docker Installation](https://docs.checkmk.com/latest/en/introduction_docker.html)
- [REST API](https://docs.checkmk.com/latest/en/rest_api.html)
- [Check Plugins](https://exchange.checkmk.com/)
- [GitHub](https://github.com/Checkmk/checkmk)
