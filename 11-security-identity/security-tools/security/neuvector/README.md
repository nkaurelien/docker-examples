# NeuVector

NeuVector is an open-source, full lifecycle container security platform. It provides runtime protection, network visibility, compliance, and vulnerability scanning for containers.

## Quick Start

```bash
# Single node deployment
docker compose up -d
```

## Access

- **Web UI**: https://localhost:8443
- **Default credentials**: admin / admin

## Deployment Options

### Single Node (Allinone)

Use `compose.yml` for single-node deployment:

```bash
docker compose up -d
```

### High Availability (HA)

For production HA deployments, use `compose.ha.yml` on 3+ nodes (odd numbers: 3, 5, 7):

```bash
# On each Allinone node, set CLUSTER_JOIN_ADDR to all node IPs
CLUSTER_JOIN_ADDR=192.168.1.10,192.168.1.11,192.168.1.12 docker compose -f compose.ha.yml up -d
```

### Enforcer Only

Deploy `compose.enforcer.yml` on additional nodes (where Allinone is NOT running):

```bash
CLUSTER_JOIN_ADDR=192.168.1.10,192.168.1.11,192.168.1.12 docker compose -f compose.enforcer.yml up -d
```

### Non-Privileged Mode

If you cannot run containers in privileged mode, use the unprivileged variants that use Linux capabilities instead:

```bash
# Allinone (non-privileged)
docker compose -f compose.unprivileged.yml up -d

# Enforcer only (non-privileged)
CLUSTER_JOIN_ADDR=192.168.1.10 docker compose -f compose.enforcer.unprivileged.yml up -d
```

**Required capabilities:**

- `SYS_ADMIN` - System administration
- `NET_ADMIN` - Network administration
- `SYS_PTRACE` - Process tracing
- `IPC_LOCK` - Lock memory

**Required security options:**

- `label:disable` - Disable SELinux labeling
- `apparmor:unconfined` - Disable AppArmor
- `seccomp:unconfined` - Disable seccomp

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `NEUVECTOR_VERSION` | `latest` | NeuVector image version |
| `CLUSTER_JOIN_ADDR` | - | Controller IP(s) for cluster join |
| `NV_PLATFORM_INFO` | `platform=Docker` | Platform identifier |
| `NV_SYSTEM_GROUPS` | - | Show system containers in Network Activity |

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 8443 | HTTPS | Manager web UI |
| 18300 | TCP | Controller REST API |
| 18301 | TCP/UDP | Controller cluster communication |
| 18400 | TCP | Enforcer communication |
| 18401 | TCP | Enforcer cluster communication |

## Components

- **Controller**: Policy management, REST API, cluster coordination
- **Enforcer**: Runtime security, network monitoring, DLP
- **Manager**: Web UI management console
- **Scanner**: Vulnerability scanning
- **Allinone**: All components in a single container

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Production Cluster                    │
├─────────────────┬─────────────────┬─────────────────────┤
│     Node 1      │     Node 2      │     Node 3+         │
│   [Allinone]    │   [Allinone]    │   [Enforcer]        │
│  Controller     │  Controller     │                     │
│  Enforcer       │  Enforcer       │                     │
│  Manager        │  Manager        │                     │
│  Scanner        │  Scanner        │                     │
└─────────────────┴─────────────────┴─────────────────────┘
```

## Features

- **Runtime Protection**: Zero-day attack prevention
- **Network Security**: Layer 7 container firewall
- **Vulnerability Scanning**: Image and registry scanning
- **Compliance**: CIS benchmarks, PCI-DSS, GDPR
- **Admission Control**: Block vulnerable images
- **DLP**: Data loss prevention for containers

## Files

| File | Description |
|------|-------------|
| `compose.yml` | Single node Allinone (privileged) |
| `compose.ha.yml` | High Availability Allinone (privileged) |
| `compose.enforcer.yml` | Enforcer only (privileged) |
| `compose.unprivileged.yml` | Allinone with capabilities (non-privileged) |
| `compose.enforcer.unprivileged.yml` | Enforcer with capabilities (non-privileged) |

## Requirements

- Docker with privileged mode or capability support
- Linux kernel modules access
- Minimum 2GB RAM per Allinone container

## Notes

- Privileged mode is recommended for full runtime security
- Non-privileged mode uses Linux capabilities (SYS_ADMIN, NET_ADMIN, SYS_PTRACE, IPC_LOCK)
- Does NOT support Mirantis Kubernetes Engine Swarm mode (use docker-compose instead)
- For Kubernetes deployments, use Helm charts instead

## References

- [NeuVector Documentation](https://open-docs.neuvector.com/)
- [NeuVector GitHub](https://github.com/neuvector/neuvector)
- [Docker Deployment Guide](https://open-docs.neuvector.com/deploying/docker)
