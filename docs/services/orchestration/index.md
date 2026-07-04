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
# https://localhost
```

### [Coolify](coolify.md)

PaaS self-hosted (alternative à Heroku/Vercel) :

```bash
cd orchestration/coolify
docker compose up -d
# http://localhost:8000
```

### [Dokploy](dokploy.md)

PaaS self-hosted (alternative à Netlify/Heroku) :

```bash
cd orchestration/dokploy
docker compose up -d
# http://localhost:3000
```

### [Arcane](arcane.md)

Dashboard moderne de gestion Docker avec Socket Proxy :

```bash
cd orchestration/arcane
docker compose up -d
# http://localhost:3552
```

## Comparatif

| Feature | Portainer | Rancher | Coolify | Dokploy | Arcane |
|---------|-----------|---------|---------|---------|--------|
| Docker Standalone | ✅ | ✅ | ✅ | ✅ | ✅ |
| Docker Swarm | ✅ | ❌ | ❌ | ✅ | ❌ |
| Kubernetes | ✅ | ✅ Native | ❌ | ❌ | ❌ |
| Cluster Creation | ❌ | ✅ | ❌ | ❌ | ❌ |
| Multi-cluster | ✅ Business | ✅ | ✅ | ✅ | ❌ |
| Légèreté | ✅ | ❌ | ❌ (Heavy) | ✅ | ✅ |

## Alternatives

- **Kubernetes Dashboard** - UI officielle K8s
- **Lens** - IDE Kubernetes desktop
- **Nomad** - Alternative légère à K8s (HashiCorp)
- **CapRover** - PaaS Docker simple

