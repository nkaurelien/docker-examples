---
title: "K3s Kubernetes Homelab — Déploiement et Administration"
description: "Architecture, déploiement automatisé Ansible (Air-Gap) et gestion des applications sur cluster K3s (Acemagic K1 Mini)"
tags: kubernetes, k3s, homelab, ansible, airgap, devops
lang: fr
---

# K3s Kubernetes Homelab (Acemagic K1 Mini)

Guide complet du cluster **K3s (Lightweight Kubernetes)** déployé sur le serveur physique **Acemagic K1 Mini** (`kamitbrains-minipc-k1.lab` / `192.168.0.205`).

---

## 🖥️ Matériel et Système

- **Hôte** : Acemagic K1 Mini PC
- **CPU** : 4 cœurs physiques / 8 vCPU
- **RAM** : 32 Go DDR4
- **Stockage** : 1 To SSD NVMe
- **OS** : Ubuntu 26.04 LTS (Kernel 7.0 generic amd64)
- **Version K3s** : `v1.31.12+k3s1` (Containerd 2.0.5)

---

## ⚡ Automatisation & Déploiement Ansible (Air-Gap)

Le cluster est provisionné via la collection officielle **[k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible)** (`k3s.orchestration`) en mode **Air-Gap** :

```bash
# 1. Télécharger en local les binaires et l'archive d'images K3s
make k3s-airgap-prep

# 2. Déployer ou mettre à jour K3s sur le K1 Mini
make k3s-deploy

# 3. Vérifier l'état du cluster
make k3s-status

# 4. Nettoyer / réinitialiser le cluster proprement
make k3s-reset
```

Lors du déploiement, Ansible configure automatiquement le contexte local **`k3s-ansible`** dans votre fichier `~/.kube/config` sur macOS.

---

## 🔒 Sécurité & Certificats TLS (Root CA Local)

Toutes les applications exposées via Traefik Ingress bénéficient de certificats SSL/TLS valides générés automatiquement par **`cert-manager`** :

- **Secret Root CA** : `cert-manager/root-ca-key-pair` (généré à partir de votre CA locale `mkcert`).
- **ClusterIssuer** : `homelab-ca-issuer`.
- **Résultat** : Accès direct en HTTPS avec le **cadenas vert sans avertissement de sécurité** dans votre navigateur.

---

## 🌐 Applications Déployées & URLs

| Application | Namespace | URL d'accès HTTPS | Description |
| :--- | :--- | :--- | :--- |
| **Homepage** | `tools` | `https://home.kamitbrains-minipc-k1.lab` | Dashboard d'accueil et portail des services |
| **Headlamp** | `headlamp` | `https://headlamp.kamitbrains-minipc-k1.lab` | Dashboard Kubernetes léger et moderne |
| **Rancher Server** | `cattle-system` | `https://rancher.kamitbrains-minipc-k1.lab` | Console d'orchestration multi-cluster |
| **IT-Tools** | `tools` | `https://it-tools.kamitbrains-minipc-k1.lab` | Boîte à outils développeur en ligne |
| **Excalidraw** | `tools` | `https://draw.kamitbrains-minipc-k1.lab` | Tableaux blancs et schémas collaboratifs |
| **Uptime Kuma** | `monitoring` | `https://status.kamitbrains-minipc-k1.lab` | Surveillance de disponibilité et status page |
| **Glances** | `monitoring` | `https://glances.kamitbrains-minipc-k1.lab` | Métriques système matériel K1 Mini en direct |
| **Umami Analytics** | `monitoring` | `https://analytics.kamitbrains-minipc-k1.lab` | Web Analytics privacy-first (Postgres backend) |
| **CouchDB** | `databases` | `https://couchdb.kamitbrains-minipc-k1.lab` | Base NoSQL Document (Fauxton UI, PVC 10Gi) |
| **PostgreSQL 16** | `databases` | `postgres.databases.svc:5432` | Base relationnelle interne (PVC 10Gi) |
| **Faster-Whisper (STT)** | `ai` | `faster-whisper.ai.svc:10300` | Moteur Speech-To-Text Wyoming (Voice AI, PVC 10Gi) |
| **HedgeDoc** | `productivity` | `https://pad.kamitbrains-minipc-k1.lab` | Éditeur de notes Markdown collaboratif |

---

## 🛠️ Modèle Multi-Environnement FastAPI (Dev / Staging / Prod)

Pour déployer vos propres APIs (ex: FastAPI) avec le pattern **Base & Overlays (Kustomize)** :

- **Emplacement du template** : `kubernetes/apps/fastapi-boilerplate/`
- **Commandes** :
  ```bash
  # Déployer DEV (https://api-dev.kamitbrains-minipc-k1.lab)
  kubectl --context k3s-ansible apply -k kubernetes/apps/fastapi-boilerplate/overlays/dev

  # Déployer STAGING (https://api-stage.kamitbrains-minipc-k1.lab)
  kubectl --context k3s-ansible apply -k kubernetes/apps/fastapi-boilerplate/overlays/staging

  # Déployer PROD (https://api.kamitbrains-minipc-k1.lab - 2 répliques HA)
  kubectl --context k3s-ansible apply -k kubernetes/apps/fastapi-boilerplate/overlays/prod
  ```

### 💡 Le constat moderne : Est-ce recommandé en production Kubernetes ?

**Non, ce n'est plus la recommandation en environnement Kubernetes** (comme l'indique l'auteur de FastAPI dans la doc officielle) :

- **Rôle du mock / démarrage immédiat** : L'image `tiangolo/uvicorn-gunicorn-fastapi` sert de boilerplate zéro-build prêt à l'emploi (validation rapide Ingress, TLS, Kustomize, DNS).
- **L'anti-pattern Gunicorn en conteneur K8s** : Gunicorn démarre autant de workers que de cœurs CPU de la machine hôte (8 workers d'emblée sur le K1 Mini), créant une double orchestration inutile et une surconsommation de mémoire vive (400-800 Mo de RAM par pod).
- **Le pattern K8s natif recommandé** :
  - **1 Pod = 1 seul process Uvicorn** (`CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]`).
  - La scalabilité et la haute disponibilité sont confiées au cluster via `spec.replicas` et le **Horizontal Pod Autoscaler (HPA)**.
  - La résilience et le redémarrage des pannes sont gérés par le Kubelet (`livenessProbe` / `readinessProbe`).
  - L'empreinte mémoire par pod tombe à seulement **~50 à 80 Mo**.

> 📖 Pour le Dockerfile complet et la configuration Kubernetes de production, consultez [kubernetes/apps/fastapi-boilerplate/README.md](file:///Volumes/X9%20Pro/Workspaces/nkaurelien/docker-examples/kubernetes/apps/fastapi-boilerplate/README.md).

---

## 🔨 Build d'Images In-Cluster Sécurisé (Kaniko)

Pour compiler vos images de conteneurs directement sur le cluster K3s (sans daemon Docker, sans droits root, en pur *userspace*) :
- **Principe** : Exécution sous forme de `Job` Kubernetes, support natif des Dockerfiles multi-stage avec `uv`, et mise en cache des couches intermédiaires.
- **Documentation et schéma Mermaid** : [kubernetes/infrastructure/ci-cd/kaniko/README.md](file:///Volumes/X9%20Pro/Workspaces/nkaurelien/docker-examples/kubernetes/infrastructure/ci-cd/kaniko/README.md).

---

## 🌐 Découverte de Services & DNS : K8s vs Docker Compose vs Swarm

### Anatomie du FQDN Kubernetes (`redis.databases.svc.cluster.local`)

Dans l'URL interne du cluster :
```text
redis://redis.databases.svc.cluster.local:6379
```

- **`redis`** : Nom du `Service` Kubernetes.
- **`databases`** : Le `Namespace` d'isolation de l'application.
- **`svc`** : Type d'enregistrement (Service par opposition à Pod éphémère).
- **`cluster.local`** : Domaine racine du cluster géré par **CoreDNS**.

### Comparatif d'Architecture DNS

| Critère | 🐳 Docker Compose | 🐝 Docker Swarm | ☸️ Kubernetes (K3s) |
| :--- | :--- | :--- | :--- |
| **Résolveur DNS** | `127.0.0.11` (daemon Docker) | DNS Swarm avec VIP (IPVS kernel) | **CoreDNS** en pod natif (`kube-system`) |
| **Format du nom** | Nom court (`redis:6379`) | Nom court ou `tasks.<nom>` | **FQDN structuré** : `<svc>.<ns>.svc.cluster.local` |
| **Multi-tenancy** | ❌ Risque de collision de nom | ❌ Risque de collision de nom | ✅ **Namespaces natifs** : isolation sans collision |
| **Stabilité IP** | IP de conteneur volatile | VIP de service | **ClusterIP** immuable routée par Kube-Proxy |

---

## 📱 Outils d'Administration Recommandés

1. **k9s (Terminal UI)** :
   ```bash
   k9s --context k3s-ansible
   ```
2. **Lens Desktop (GUI Mac)** :
   - Connecté via `~/.kube/config` (serveur MCP configuré).
3. **Headlamp (Web UI)** :
   - Accès via `https://headlamp.kamitbrains-minipc-k1.lab` avec le token administrateur.
