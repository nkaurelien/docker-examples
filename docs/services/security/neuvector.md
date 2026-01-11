# NeuVector

NeuVector est une plateforme de sécurité container open-source offrant protection runtime, visibilité réseau, compliance et scan de vulnérabilités.

## Quick Start

```bash
cd security/neuvector
docker compose up -d
```

## Accès

- **Web UI**: https://localhost:8443
- **Credentials**: admin / admin

## Fichiers Disponibles

| Fichier | Description |
|---------|-------------|
| `compose.yml` | Single node Allinone (privileged) |
| `compose.ha.yml` | High Availability (3+ nodes) |
| `compose.enforcer.yml` | Enforcer only (privileged) |
| `compose.unprivileged.yml` | Allinone avec capabilities |
| `compose.enforcer.unprivileged.yml` | Enforcer avec capabilities |

## Déploiement

### Single Node

```bash
docker compose up -d
```

### High Availability

Déployer sur 3+ nodes (nombres impairs : 3, 5, 7) :

```bash
CLUSTER_JOIN_ADDR=192.168.1.10,192.168.1.11,192.168.1.12 \
  docker compose -f compose.ha.yml up -d
```

### Enforcer Only

Sur les nodes additionnels (sans Allinone) :

```bash
CLUSTER_JOIN_ADDR=192.168.1.10,192.168.1.11,192.168.1.12 \
  docker compose -f compose.enforcer.yml up -d
```

### Mode Non-Privilegié

Si le mode privileged n'est pas disponible :

```bash
docker compose -f compose.unprivileged.yml up -d
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `NEUVECTOR_VERSION` | `latest` | Version de l'image |
| `CLUSTER_JOIN_ADDR` | - | IP(s) des controllers |
| `NV_PLATFORM_INFO` | `platform=Docker` | Identifiant plateforme |

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 8443 | HTTPS | Web UI |
| 18300 | TCP | Controller REST API |
| 18301 | TCP/UDP | Controller cluster |
| 18400 | TCP | Enforcer communication |
| 18401 | TCP | Enforcer cluster |

## Mode Privileged vs Capabilities

### Privileged (Recommandé)

```yaml
services:
  allinone:
    privileged: true
```

### Capabilities (Alternative)

```yaml
services:
  allinone:
    cap_add:
      - SYS_ADMIN
      - NET_ADMIN
      - SYS_PTRACE
      - IPC_LOCK
    security_opt:
      - label:disable
      - apparmor:unconfined
      - seccomp:unconfined
```

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

- **Runtime Protection** - Prévention attaques zero-day
- **Network Security** - Firewall container Layer 7
- **Vulnerability Scanning** - Scan images et registries
- **Compliance** - CIS benchmarks, PCI-DSS, GDPR
- **Admission Control** - Blocage images vulnérables
- **DLP** - Data Loss Prevention

## Références

- [NeuVector Documentation](https://open-docs.neuvector.com/)
- [NeuVector GitHub](https://github.com/neuvector/neuvector)
- [Docker Deployment Guide](https://open-docs.neuvector.com/deploying/docker)
