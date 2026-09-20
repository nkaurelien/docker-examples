---
tags: boilerplates, helm, values, kubernetes
---

# Helm Values & Configurations Déclaratives

Ce dossier centralise les fichiers de configuration `values.yaml` personnalisés pour déployer les charts Helm officiels sur le cluster **K3s** du K1 Mini (ou via Argo CD).

---

## 📁 Structure

```text
helm/
├── README.md
└── values/
    ├── argocd/
    │   └── values.yaml               # ArgoCD GitOps avec Ingress Traefik & TLS
    ├── harbor/
    │   └── values.yaml               # Harbor Enterprise OCI Registry & Trivy avec persistance K3s
    └── monitoring/
        └── kube-prometheus-stack-values.yaml  # Prometheus, Grafana, Alertmanager avec persistance NVMe
```

---

## 🚀 Commandes de Déploiement Direct

### 1. Déployer Argo CD
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  -f helm/values/argocd/values.yaml
```

### 2. Déployer Harbor OCI Registry & Trivy
```bash
helm repo add harbor https://helm.goharbor.io
helm repo update
helm upgrade --install harbor harbor/harbor \
  --namespace code-management \
  --create-namespace \
  -f helm/values/harbor/values.yaml \
  --set harborAdminPassword="$(cat .secrets/harbor-admin-password)"
```

### 3. Déployer la stack Prometheus / Grafana
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f helm/values/monitoring/kube-prometheus-stack-values.yaml
```
