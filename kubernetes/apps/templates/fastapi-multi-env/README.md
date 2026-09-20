---
tags: kubernetes, fastapi, kustomize, devops, multi-environment
---

# Guide de Déploiement Multi-Environnement (Dev, Staging, Prod) — FastAPI

Ce guide documente le pattern officiel Kubernetes / Kustomize (**Base & Overlays**) pour déployer une API (comme FastAPI) sur plusieurs environnements isolés sur le cluster K3s du K1 Mini.

---

## 🎯 Objectifs

1. **Isolation par Namespaces** : Aucun risque de collision entre les environnements de Dev, Staging et Production.
2. **Configuration Déclarative (Zero Duplication)** : Les manifestes communs (`Deployment`, `Service`, `Ingress`) sont mutualisés dans `base/`.
3. **Différenciation par Overlays** :
   - **DEV** : 1 réplique, `DEBUG=true`, accessible sur `https://api-dev.kamitbrains-minipc-k1.lab`.
   - **STAGING** : 1 réplique, configuration proche de la prod, accessible sur `https://api-stage.kamitbrains-minipc-k1.lab`.
   - **PROD** : 2 répliques (Haute Disponibilité), `DEBUG=false`, accessible sur `https://api.kamitbrains-minipc-k1.lab`.
4. **Certificats TLS Automatiques** : Chaque environnement obtient un certificat SSL/TLS valide et sécurisé par `cert-manager` et votre Root CA local.

---

## 📁 Arborescence

```text
kubernetes/apps/templates/fastapi-multi-env/
├── README.md               # Le présent guide
├── base/                   # Manifestes partagés et neutres
│   ├── deployment.yaml     # Conteneur, probes health, ports
│   ├── service.yaml        # Service ClusterIP (Port 80 -> 8000)
│   ├── ingress.yaml        # Template d'Ingress Traefik + cert-manager
│   └── kustomization.yaml  # Assemblage du socle commun
│
└── overlays/               # Déclinaisons par environnement
    ├── dev/
    │   └── kustomization.yaml   # Namespace dev, préfixe dev-, ConfigMap dev
    ├── staging/
    │   └── kustomization.yaml   # Namespace staging, préfixe staging-
    └── prod/
        └── kustomization.yaml   # Namespace prod, 2 répliques, Host prod
```

---

## 🚀 Guide d'Utilisation Pratique

### 1. Prérequis : Créer les Namespaces (une seule fois)

```bash
kubectl --context k3s-ansible create namespace dev --dry-run=client -o yaml | kubectl --context k3s-ansible apply -f -
kubectl --context k3s-ansible create namespace staging --dry-run=client -o yaml | kubectl --context k3s-ansible apply -f -
kubectl --context k3s-ansible create namespace prod --dry-run=client -o yaml | kubectl --context k3s-ansible apply -f -
```

---

### 2. Déployer un Environnement spécifique

Grâce à `-k` (Kustomize natif dans `kubectl`), une seule commande suffit :

#### 👉 Déployer l'environnement de DEV :
```bash
kubectl --context k3s-ansible apply -k kubernetes/apps/templates/fastapi-multi-env/overlays/dev
```

#### 👉 Déployer l'environnement de STAGING :
```bash
kubectl --context k3s-ansible apply -k kubernetes/apps/templates/fastapi-multi-env/overlays/staging
```

#### 👉 Déployer l'environnement de PROD :
```bash
kubectl --context k3s-ansible apply -k kubernetes/apps/templates/fastapi-multi-env/overlays/prod
```

---

### 3. Visualiser et Vérifier le Rendu (Dry-Run / Build)

Pour vérifier le YAML généré par Kustomize sans l'appliquer sur le cluster :
```bash
kubectl kustomize kubernetes/apps/templates/fastapi-multi-env/overlays/dev
kubectl kustomize kubernetes/apps/templates/fastapi-multi-env/overlays/prod
```

---

### 4. Résolution DNS Locale (`hostctl`)

Pour accéder aux trois environnements depuis le navigateur de votre Mac :
```bash
sudo hostctl add domains kamitbrains-homelab \
  api-dev.kamitbrains-minipc-k1.lab \
  api-stage.kamitbrains-minipc-k1.lab \
  api.kamitbrains-minipc-k1.lab \
  --ip 192.168.0.210
```

---

### 5. Supprimer un Environnement proprement

Pour supprimer uniquement l'environnement de dev sans toucher à la prod :
```bash
kubectl --context k3s-ansible delete -k kubernetes/apps/templates/fastapi-multi-env/overlays/dev
```
