# Bind9 DNS Server

BIND 9 provides software for Domain Name System (DNS) management including both defining domain names authoritatively for a given DNS zone, and recursively resolving domain names to their IP addresses.

## Features

- Authoritative DNS server for local domains
- Recursive DNS resolver with forwarding
- DNSSEC validation
- Zone file management for `apps.local` domain

## Quick Start

1. Edit the zone files to match your network:
   - `records/db.apps.local` - Update IP addresses (default: 192.168.1.100)
   - `records/db.192.168.1` - Update reverse lookup records

2. Start the service:
```bash
docker compose up -d
```

3. Test DNS resolution:
```bash
# Query the DNS server
dig @localhost traefik.apps.local

# Or using nslookup
nslookup traefik.apps.local 127.0.0.1
```

4. Configure your system to use this DNS server:
   - Set `127.0.0.1` as your primary DNS server
   - Or configure your router to use the Docker host IP

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TZ` | `Europe/Paris` | Timezone |
| `BIND9_USER` | `bind` | User running the named process |

### Volumes

| Path | Description |
|------|-------------|
| `./config/named.conf` | Main BIND configuration |
| `./cache` | DNS cache data |
| `./records` | Zone files (db.apps.local, etc.) |

### Adding New Domains

1. Edit `records/db.apps.local` to add new A records:
```
myservice       IN      A       192.168.1.100
```

2. Reload the configuration:
```bash
docker exec bind9 rndc reload
```

## Debugging

```bash
# View logs
docker logs -f bind9

# Interactive shell
docker exec -it bind9 /bin/bash

# Check configuration syntax
docker exec bind9 named-checkconf /etc/bind/named.conf

# Check zone file syntax
docker exec bind9 named-checkzone apps.local /var/lib/bind/db.apps.local
```

## Documentation

- [BIND 9 Official Documentation](https://bind9.readthedocs.io/)
- [Ubuntu BIND9 Docker Image](https://hub.docker.com/r/ubuntu/bind9)
