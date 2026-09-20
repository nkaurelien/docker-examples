# Harbor OCI & Artifact Registry

[Harbor](https://goharbor.io/) is an open-source trusted cloud-native artifact registry that stores, signs, and scans container images and Helm charts.

---

## 🌟 Key Features

- **OCI Registry Compliance**: Store Docker, OCI images, Wasm modules, and Helm charts.
- **Trivy Vulnerability Scanner**: Automatic vulnerability analysis on image push with policy enforcement.
- **Role-Based Access Control (RBAC)**: Fine-grained permissions per project.
- **Traefik v3 Ingress**: Automated TLS termination and reverse proxy routing.
- **Dual Deployment Options**: Deployable via Docker Compose (Ansible) or Kubernetes K3s (Helm).

---

## 🚀 Quick Start (Docker Compose via Ansible)

Deploy Harbor to the homelab environment:

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags harbor --limit homelab
```

### Docker CLI Authentication

```bash
docker login harbor.kamitbrains-minipc-k1.lab -u admin -p <ADMIN_PASSWORD>
```

---

## ☸️ Kubernetes K3s Deployment (Helm)

Harbor is deployed in the `code-management` namespace via the official Helm chart:

```bash
helm upgrade --install harbor harbor/harbor \
  --namespace code-management \
  --create-namespace \
  -f helm/values/harbor/values.yaml \
  --set harborAdminPassword="$(cat .secrets/harbor-admin-password)"
```

---

## 🔐 Credentials Management & Reset

Admin credentials are saved securely in `.secrets/harbor-admin-password`. To reset the administrator password in PostgreSQL:

```bash
# Docker Compose
docker exec harbor-db psql -U postgres -d registry -c "UPDATE harbor_user SET salt='', password='', password_version='' WHERE user_id = 1;"
docker exec redis redis-cli flushall
cd /opt/harbor && docker compose restart core

# Kubernetes K3s
kubectl exec -n code-management harbor-database-0 -- psql -U postgres -d registry -c "UPDATE harbor_user SET salt='', password='', password_version='' WHERE user_id = 1;"
kubectl rollout restart deployment/harbor-core -n code-management
```
