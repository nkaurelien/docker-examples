---
tags: boilerplates, kubernetes, k3s, roadmap, homelab
---

# Kubernetes Architecture & Homelab (K3s)

Ce dossier regroupe les manifestes Kubernetes, configurations Kustomize et déploiements d'applications sur le cluster **K3s** du serveur **Acemagic K1 Mini** (`192.168.0.210`).

---

## 🗺️ Roadmap de Déploiement

👉 **[Consulter la feuille de route complète (ROADMAP.md)](ROADMAP.md)**

---

## 📁 Organisation du Dossier `kubernetes/`

```text
kubernetes/
├── ROADMAP.md
├── README.md
├── infrastructure/                   # Services de base de la plateforme
│   ├── cert-manager/                 # ClusterIssuers (Local Root CA mkcert + Let's Encrypt)
│   │   ├── cluster-issuers.yaml
│   │   └── kustomization.yaml
│   └── ingress/                      # Middlewares et Ingress Traefik natifs
│       └── traefik-dashboard.yaml
│
└── apps/                             # Applications Homelab
    ├── code-management/
    │   └── harbor.yaml               # Registre OCI Harbor (Chart Helm goharbor/harbor)
    ├── fastapi-boilerplate/          # Template d'API multi-environnement (dev, staging, prod)
    │   ├── base/
    │   └── overlays/
    ├── monitoring/
    │   ├── uptime-kuma.yaml          # Status page (PVC local-path, Ingress TLS)
    │   ├── glances.yaml              # Monitoring système DaemonSet hôte
    │   └── umami.yaml                # Analytics Web (PostgreSQL + Ingress TLS)
    ├── dev-tools/
    │   ├── it-tools.yaml             # Boîte à outils développeur
    │   └── excalidraw.yaml           # Schémas et tableaux blancs collaboratifs
    ├── databases/
    │   ├── postgres.yaml             # PostgreSQL 16 (PVC 10Gi local-path)
    │   ├── redis.yaml                # Valkey 8 (Fork Open-Source de Redis, PVC 2Gi)
    │   └── couchdb.yaml              # Apache CouchDB 3.4 (PVC 10Gi local-path, Ingress TLS)
    ├── security/
    │   └── infisical.yaml            # Infisical Secret Manager (Mutualisé PG 16 + Valkey, Ingress TLS)
    ├── ai/
    │   └── faster-whisper.yaml       # Faster-Whisper Wyoming STT Server (PVC 10Gi local-path, Port 10300)
    └── productivity/
        ├── hedgedoc.yaml             # Prise de notes Markdown collaborative
        └── homepage.yaml             # Tableau de bord d'accueil Homelab
```

---

## 🌐 Applications Actives & URL d'Accès

Tous les services ci-dessous sont exposés via **Traefik Ingress** et sécurisés par certificat TLS valide (signé automatiquement par votre **Root CA local** via `cert-manager`) :

| Application | Namespace | URL / Endpoint d'accès | Domaine / Rôle |
| :--- | :--- | :--- | :--- |
| **Harbor OCI Registry** | `code-management` | `https://harbor.kamitbrains-minipc-k1.lab` | Registre OCI & Dépôt d'Artefacts d'Entreprise (Helm + Trivy) |
| **Homepage** | `tools` | `https://home.kamitbrains-minipc-k1.lab` | Portail d'accueil du Homelab |
| **Infisical** | `security` | `https://infisical.kamitbrains-minipc-k1.lab` | Gestionnaire de Secrets & Clés (Mutualisé PG + Valkey) |
| **Headlamp (UI K8s)** | `headlamp` | `https://headlamp.kamitbrains-minipc-k1.lab` | Dashboard cluster léger |
| **Rancher Server** | `cattle-system` | `https://rancher.kamitbrains-minipc-k1.lab` | Console multi-cluster |
| **IT-Tools** | `tools` | `https://it-tools.kamitbrains-minipc-k1.lab` | Outils dev en ligne |
| **Excalidraw** | `tools` | `https://draw.kamitbrains-minipc-k1.lab` | Tableaux blancs virtuels |
| **Uptime Kuma** | `monitoring` | `https://status.kamitbrains-minipc-k1.lab` | Surveillance & Status page |
| **Glances** | `monitoring` | `https://glances.kamitbrains-minipc-k1.lab` | Métriques K1 Mini (CPU/RAM/I/O) |
| **Umami Analytics** | `monitoring` | `https://analytics.kamitbrains-minipc-k1.lab` | Web Analytics privacy-first |
| **CouchDB** | `databases` | `https://couchdb.kamitbrains-minipc-k1.lab` | Base NoSQL Document (Fauxton UI) |
| **PostgreSQL 16** | `databases` | `postgres.databases.svc:5432` | Base relationnelle mutualisée |
| **Valkey 8 (ex-Redis)** | `databases` | `redis.databases.svc:6379` | Cache in-memory & file de tâches mutualisé |
| **Faster-Whisper (STT)** | `ai` | `faster-whisper.ai.svc:10300` | Moteur Speech-To-Text Wyoming (Voice AI) |
| **HedgeDoc** | `productivity` | `https://pad.kamitbrains-minipc-k1.lab` | Éditeur Markdown partagé |

> 💡 **Note sur Homepage et ses alternatives (Homarr & Heimdall) :**
> - **Homepage (Choix actuel)** : Configuration 100% déclarative via fichiers YAML / ConfigMaps K8s (parfait pour GitOps), widgets Kubernetes natifs (statut des pods/nœuds), ultra-léger et rapide.
> - **Homarr** : Dashboard moderne et interactif avec grille glisser-déposer (drag & drop) et gestion intégrée depuis l'interface Web (très visuel, supporte Docker/K8s et de nombreux widgets).
> - **Heimdall** : Solution classique basée sur PHP/Laravel. Simple lanceur d'applications avec tuiles et icônes, idéal pour une configuration graphique simple sans YAML.

---

## 💻 Configuration DNS Locale (Mac)

Pour accéder à tous ces services depuis votre navigateur sans erreur DNS, ajoutez-les à votre `hostctl` :

```bash
sudo hostctl add domains kamitbrains-homelab \
  rancher.kamitbrains-minipc-k1.lab \
  headlamp.kamitbrains-minipc-k1.lab \
  home.kamitbrains-minipc-k1.lab \
  analytics.kamitbrains-minipc-k1.lab \
  it-tools.kamitbrains-minipc-k1.lab \
  draw.kamitbrains-minipc-k1.lab \
  status.kamitbrains-minipc-k1.lab \
  glances.kamitbrains-minipc-k1.lab \
  pad.kamitbrains-minipc-k1.lab \
  couchdb.kamitbrains-minipc-k1.lab \
  infisical.kamitbrains-minipc-k1.lab \
  --ip 192.168.0.210
```

---

## 🧭 DNS & Résolution Interne : Kubernetes vs Docker Compose vs Swarm

### 1. Anatomie d'un FQDN Kubernetes

Dans l'URL interne du cluster :
```text
redis://redis.databases.svc.cluster.local:6379
```

Le nom de domaine complet (**FQDN**) est découpé en 4 segments hiérarchiques :

$$\underbrace{\text{redis}}_{\text{1. Service}}.\underbrace{\text{databases}}_{\text{2. Namespace}}.\underbrace{\text{svc}}_{\text{3. Type d'objet}}.\underbrace{\text{cluster.local}}_{\text{4. Racine DNS du Cluster}}$$

- **`redis`** : Nom de l'objet Kubernetes `Service` (`metadata.name: redis`).
- **`databases`** : Le `Namespace` d'isolation où réside le service.
- **`svc`** : Le type d'objet (abréviation de *Service*, par opposition aux IPs éphémères de `pod`).
- **`cluster.local`** : Le domaine racine par défaut de votre cluster (géré par CoreDNS).

### 2. Comparatif de Découverte de Services : K8s vs Compose vs Swarm

| Critère | 🐳 Docker Compose | 🐝 Docker Swarm | ☸️ Kubernetes (K3s) |
| :--- | :--- | :--- | :--- |
| **Serveur DNS** | DNS interne Docker daemon (`127.0.0.11`) | DNS interne Swarm avec VIP (Virtual IP) | **CoreDNS** en pod natif (`kube-system`) |
| **Format du nom** | Nom court du service (`redis:6379`) | Nom court (`redis:6379`) ou `tasks.<nom>` | **FQDN hiérarchique** : `<svc>.<ns>.svc.cluster.local` |
| **Isolation / Multi-tenant** | ❌ Aucune (isolé par réseau bridge local) | ❌ Aucune (isolé par réseau overlay) | ✅ **Namespaces natifs** : plusieurs services peuvent s'appeler `redis` sans collision |
| **Communication Inter-Projets** | Manuelle (nécessite un `external: true` bridge) | Manuelle (nécessite un overlay partagé) | **Natif & Transparent** : accessible via `<svc>.<namespace>` |
| **Résilience & IP** | IP de conteneur éphémère | VIP de service routée par IPVS kernel | **ClusterIP** immuable routée par iptables / Kube-Proxy |
