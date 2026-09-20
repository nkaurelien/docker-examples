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
kubectl --context k3s-ansible delete -k kubernetes/apps/fastapi-boilerplate/overlays/dev
```

---

## 🏗️ Architecture du Conteneur : Image de Mock vs Conteneur Production

### Pourquoi l'image `tiangolo/uvicorn-gunicorn-fastapi` pour le boilerplate ?

Dans ce boilerplate, l'image `tiangolo/uvicorn-gunicorn-fastapi:python3.11-slim` est utilisée comme image de démonstration immédiate (**zero-build**) :
- Elle est maintenue par l'auteur de FastAPI (**Sebastián Ramírez**).
- Elle contient déjà FastAPI, Uvicorn, Gunicorn et un endpoint `GET /` retournant `Hello World!`.
- Elle permet de valider toute l'infrastructure (Kustomize, Traefik Ingress, cert-manager TLS, DNS hostctl) sans avoir besoin de builder et pousser une image sur un registry privé au préalable.

### Le constat moderne : Est-ce recommandé en production Kubernetes ?

**Non, ce n'est plus la recommandation moderne en environnement conteneurisé/orchestré** (comme le souligne également Sebastián Ramírez dans la documentation officielle de FastAPI).

L'image combine **Gunicorn** (process manager multi-processus) et **Uvicorn** (serveur ASGI asynchrone). Dans un environnement Kubernetes, ce pattern engendre un **anti-pattern de double orchestration** :

| Aspect | Gunicorn + Uvicorn (Image tiangolo) | Modèle Kubernetes Natif (Recommandé) |
| :--- | :--- | :--- |
| **Gestion du scale** | Gunicorn gère plusieurs workers par Pod (`workers = CPU cores`, ex: 8 workers d'un coup sur le K1 Mini). | **Kubernetes** gère le scale horizontalement via les `replicas` de Pods avec le **Horizontal Pod Autoscaler (HPA)**. |
| **Gestion des pannes** | Gunicorn surveille et redémarre les workers en interne. | Le **Kubelet** surveille le conteneur et le redémarre automatiquement selon les sondes `livenessProbe` et `readinessProbe`. |
| **Consommation mémoire** | Un seul Pod lance 8 processus Python parallèles, consommant 400 à 800 Mo de RAM dès le démarrage. | Chaque Pod exécute **1 seul process Uvicorn** (`1 worker`). L'empreinte mémoire par Pod est minimale (~50 à 80 Mo). |
| **Répartition de charge** | Gunicorn partage la socket Unix/TCP sur une seule machine hôte. | Le **Service K8s**, Kube-Proxy et l'Ingress Traefik distribuent le trafic de manière équilibrée sur tous les Pods du cluster. |

### Bonnes pratiques : Dockerfile de Production recommandé

Pour vos véritables projets FastAPI déployés sur le cluster, utilisez un conteneur dédié n'exécutant qu'**un seul processus Uvicorn** :

```dockerfile
# Dockerfile recommandé en production K8s
FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

# Exécution en utilisateur non-privilégié (Bonne pratique de sécurité CIS / Snyk)
USER 1001

# 1 seul worker Uvicorn : Kubernetes gère le scale via spec.replicas !
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Dans `deployment.yaml` :
```yaml
containers:
  - name: api
    image: registry.kamitbrains.local/mon-api:v1.0.0
    ports:
      - containerPort: 8000
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
      limits:
        cpu: 500m
        memory: 256Mi
```
