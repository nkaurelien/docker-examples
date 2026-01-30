# Bind9 DNS Server

BIND 9 is the most widely used DNS server software on the Internet. It provides authoritative DNS for local domains and recursive resolution with forwarding.

## Quick Start

```bash
cd 01-infrastructure/bind9/
docker compose up -d
```

## Configuration

### Directory Structure

```
bind9/
├── compose.yml
├── config/
│   └── named.conf        # Main BIND configuration
├── cache/                # DNS cache (auto-generated)
└── records/
    ├── db.apps.local     # Zone file for apps.local
    └── db.192.168.1      # Reverse DNS zone
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TZ` | `Europe/Paris` | Timezone |
| `BIND9_USER` | `bind` | User running the named process |

## Zone File Syntax

### Key Directives

```dns
$TTL 1h              ; Default cache time for records
$ORIGIN apps.local.  ; Base domain (optional, uses zone name by default)
```

| Directive | Description |
|-----------|-------------|
| `$TTL` | Time To Live - how long resolvers cache records |
| `$ORIGIN` | Base domain appended to unqualified names |

### SOA Record

```dns
@  IN  SOA  ns1.apps.local. admin.apps.local. (
            2024013001  ; Serial (YYYYMMDDNN)
            3600        ; Refresh (1 hour)
            600         ; Retry (10 minutes)
            604800      ; Expire (1 week)
            1800 )      ; Negative Cache TTL
```

| Field | Description |
|-------|-------------|
| Serial | Version number, increment on each change |
| Refresh | How often secondaries check for updates |
| Retry | Wait time before retrying failed refresh |
| Expire | How long secondaries keep data without refresh |
| Negative TTL | Cache time for NXDOMAIN responses |

### Record Types

```dns
; A Record - hostname to IPv4
traefik     IN  A     192.168.1.100

; CNAME - alias to another hostname
www         IN  CNAME traefik.apps.local.

; PTR - reverse lookup (IP to hostname)
100         IN  PTR   apps.local.

; Wildcard - catch-all for undefined subdomains
*           IN  A     192.168.1.100
```

## ACL Configuration

The `named.conf` uses an ACL to restrict queries to internal networks:

```dns
acl internal {
    192.168.0.0/16;
    172.16.0.0/12;
    10.0.0.0/8;
    localhost;
    localnets;
};

options {
    allow-query { internal; };
    allow-recursion { internal; };
};
```

## Adding New Services

1. Edit `records/db.apps.local`:

```dns
myservice   IN  A   192.168.1.100
```

2. Increment the serial number in SOA record

3. Reload configuration:

```bash
docker exec bind9 rndc reload
```

## Testing

```bash
# Query the DNS server
dig @localhost traefik.apps.local

# Reverse lookup
dig @localhost -x 192.168.1.100

# Check zone file syntax
docker exec bind9 named-checkzone apps.local /var/lib/bind/db.apps.local
```

## Client Configuration

### Option 1: System DNS

Set `127.0.0.1` (or Docker host IP) as primary DNS in:

- macOS: System Preferences → Network → DNS
- Linux: `/etc/resolv.conf` or NetworkManager
- Windows: Network adapter settings

### Option 2: Router DNS

Configure your router to use the Docker host as DNS server for the entire network.

## Troubleshooting

```bash
# View logs
docker logs -f bind9

# Check configuration syntax
docker exec bind9 named-checkconf /etc/bind/named.conf

# Interactive shell
docker exec -it bind9 /bin/bash
```

## Documentation

- [BIND 9 Official Documentation](https://bind9.readthedocs.io/)
- [Ubuntu BIND9 Docker Image](https://hub.docker.com/r/ubuntu/bind9)
