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

### 2. Déployer la stack Prometheus / Grafana
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f helm/values/monitoring/kube-prometheus-stack-values.yaml
```
