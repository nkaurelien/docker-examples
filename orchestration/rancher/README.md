# Rancher

Rancher is an open-source Kubernetes management platform that simplifies deploying and managing Kubernetes clusters.

## Quick Start

```bash
docker compose up -d
```

## Access

- **Web UI**: https://localhost
- **Default port**: 443 (HTTPS), 80 (HTTP redirect)

## First Login

1. Get the bootstrap password:
   ```bash
   docker logs rancher 2>&1 | grep "Bootstrap Password:"
   ```

2. Or retrieve it from the container:
   ```bash
   docker exec rancher cat /var/lib/rancher/initial-password
   ```

3. Open https://localhost and use the bootstrap password
4. Set your admin password when prompted

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `AUDIT_LEVEL` | `0` | Audit log level (0=disabled, 1=metadata, 2=request, 3=request+response) |

## Volumes

- `rancher-data`: Persists Rancher configuration, clusters, and state

## Requirements

- Docker with privileged mode support
- Ports 80 and 443 available
- Minimum 4GB RAM recommended

## Notes

- The container runs in **privileged mode** (required for Rancher)
- First startup may take a few minutes
- For production, use a proper TLS certificate and external database

## Alternatives

Other orchestration and container management tools to consider:

**Kubernetes Management:**

- [Portainer](../portainer/) - Docker/Kubernetes/Swarm management UI
- Kubernetes Dashboard - Official K8s web UI
- Lens - Kubernetes IDE (desktop app)
- Headlamp - Modern Kubernetes UI

**Lightweight Orchestration:**

- Nomad (HashiCorp) - Lightweight alternative to Kubernetes
- Docker Swarm - Native Docker orchestration
- Coolify - Self-hosted PaaS (Heroku/Vercel alternative)
- CapRover - Simple Docker PaaS

**GitOps/CD:**

- ArgoCD - GitOps continuous delivery for Kubernetes
- FluxCD - GitOps toolkit
- Drone CI - Lightweight CI/CD

**Service Discovery & Mesh:**

- Consul (HashiCorp) - Service discovery and mesh
- Linkerd - Lightweight service mesh

**Lightweight Kubernetes:**

- K3s - Lightweight Kubernetes (Rancher Labs)
- MicroK8s - Minimal Kubernetes (Canonical)
- k0s - Zero friction Kubernetes
