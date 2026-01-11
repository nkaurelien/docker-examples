# Orchestration

Outils de gestion et orchestration de containers.

## Services Disponibles

### [Portainer](portainer.md)

Interface web pour Docker/Kubernetes/Swarm :

```bash
cd orchestration/portainer
docker compose up -d
# https://localhost:9443
```

### [Rancher](rancher.md)

Plateforme de management Kubernetes :

```bash
cd orchestration/rancher
docker compose up -d
# https://localhost (admin/voir logs)
```

## Comparatif

| Feature | Portainer | Rancher |
|---------|-----------|---------|
| Docker Standalone | ✅ | ✅ |
| Docker Swarm | ✅ | ❌ |
| Kubernetes | ✅ | ✅ Native |
| Cluster Creation | ❌ | ✅ |
| Multi-cluster | ✅ Business | ✅ |
| Légèreté | ✅ | ❌ |

## Alternatives

- **Kubernetes Dashboard** - UI officielle K8s
- **Lens** - IDE Kubernetes desktop
- **Nomad** - Alternative légère à K8s (HashiCorp)
- **Coolify** - PaaS self-hosted
- **CapRover** - PaaS Docker simple
