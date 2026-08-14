# Container Orchestration

Tools for managing, orchestrating, and deploying containers at scale.

## Existing Projects

- **arcane/** - Lightweight Docker stack and container manager
- **coolify/** - Self-hostable PaaS (Vercel/Heroku alternative)
- **dokploy/** - Self-hostable PaaS (Netlify/Heroku alternative)
- **portainer/** - Docker & Swarm container management UI
- **virtualization/** - OS virtualization examples with Docker
- **k8s-cert-manager/** - cert-manager setup for Kubernetes TLS
- **k8s-longhorn/** - Longhorn distributed storage for Kubernetes

## Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Portainer** | Container management platform | [portainer/portainer](https://github.com/portainer/portainer) |
| **Rancher** | Complete container management platform | [rancher/rancher](https://github.com/rancher/rancher) |
| **K3s** | Lightweight Kubernetes distribution | [k3s-io/k3s](https://github.com/k3s-io/k3s) |
| **K0s** | Zero-friction Kubernetes | [k0sproject/k0s](https://github.com/k0sproject/k0s) |
| **MicroK8s** | Lightweight Kubernetes for workstations | [canonical/microk8s](https://github.com/canonical/microk8s) |
| **Docker Swarm** | Native Docker clustering | Built into Docker |
| **Nomad** | Workload orchestrator by HashiCorp | [hashicorp/nomad](https://github.com/hashicorp/nomad) |
| **Yacht** | Container management UI | [SelfhostedPro/Yacht](https://github.com/SelfhostedPro/Yacht) |
| **Dockge** | Self-hosted Docker Compose stack manager | [louislam/dockge](https://github.com/louislam/dockge) |
| **Coolify** | Self-hostable Heroku/Netlify alternative | [coollabsio/coolify](https://github.com/coollabsio/coolify) |
| **CapRover** | PaaS for Docker deployments | [caprover/caprover](https://github.com/caprover/caprover) |
| **Arcane** | Modern self-hosted Docker dashboard | [getarcaneapp/arcane](https://github.com/getarcaneapp/arcane) |

## Quick Start

```bash
cd portainer/
docker compose up -d
```

Access Portainer at `http://portainer.apps.local`.
