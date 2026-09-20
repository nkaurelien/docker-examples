---
tags: ansible, boilerplates, k3s, kubernetes, openstack
---

# Ansible Infrastructure & Orchestration

Ce dossier contient la suite de playbooks, rôles et inventaires Ansible pour l'automatisation de nos infrastructures, services Docker et clusters Kubernetes.

---

## 🏗️ Architecture des Environnements

| Environnement | Hôte / IP | Système | Rôle principal |
| :--- | :--- | :--- | :--- |
| **K1 Mini (Homelab)** | `kamitbrains-minipc-k1.lab`<br>`192.168.0.210` | Ubuntu 26.04 LTS (4c/8t, 32 Go RAM) | **Cluster K3s Kubernetes** (Air-Gap / k3s-ansible) |
| **Contabo (FR)** | `contabo_server_fr` | Ubuntu LTS | Docker Stacks & Reverse Proxy Traefik |
| **Laptop AsOne4Health** | `192.168.0.195` | Linux | Services centraux AsOne4Health / CouchDB |

---

## ☸️ Cluster Kubernetes K3s (K1 Mini)

Le déploiement de K3s est orchestré avec la collection officielle **[k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible)** (`k3s.orchestration`) en mode **Air-Gap**.

### 1. Fichiers Dédiés K3s

- **`k3s-io-inventory.yml`** : Inventaire ciblant le nœud `k1-mini` avec configuration du endpoint `192.168.0.210:6443` et activation d'Air-Gap (`airgap_dir`).
- **`k3s-io-deploy.yml`** : Playbook appelant `k3s.orchestration.site`.
- **`k3s-io-reset.yml`** : Playbook de désinstallation et nettoyage complet appelant `k3s.orchestration.reset`.
- **`scripts/prepare-airgap.sh`** : Télécharge localement les binaires et images K3s dans `airgap/`.

### 2. Commandes d'Exploitation K3s

```bash
# Télécharger / mettre à jour les artefacts Air-Gap (k3s binary + images tarball)
./scripts/prepare-airgap.sh v1.31.12+k3s1 amd64

# Déployer ou mettre à jour le cluster K3s
make k3s-deploy
# ou manuellement :
ansible-playbook -i k3s-io-inventory.yml k3s-io-deploy.yml

# Réinitialiser / désinstaller proprement K3s
make k3s-reset
# ou manuellement :
ansible-playbook -i k3s-io-inventory.yml k3s-io-reset.yml

# Vérifier le statut du cluster (depuis le Mac)
make k3s-status
```

### 3. Contrôle à Distance du Cluster

Le playbook fusionne automatiquement le contexte `k3s-ansible` dans votre `~/.kube/config`.

```bash
# Utiliser kubectl directement
kubectl --context k3s-ansible get nodes -o wide
kubectl --context k3s-ansible get pods -A

# Définir le contexte par défaut
kubectl config use-context k3s-ansible

# Interface Terminal interactive k9s
k9s --context k3s-ansible

# Interface Graphique Lens Desktop
# Ouvrir Lens -> le cluster "k3s-ansible" est automatiquement détecté dans ~/.kube/config
```

---

## ☁️ Module OpenStack (Étude)

Un rôle documentaire a été initié sous **`roles/openstack/`** pour préparer l'évaluation d'OpenStack :
- **`roles/openstack/README.md`** : Analyse de dimensionnement et raisons du maintien prioritaire de K3s sur le K1 mini.
- **`roles/openstack/TODO.md`** : Roadmap d'évaluation et options futures (Proxmox VE, KubeVirt, MicroStack).

---

## 🐳 Stacks Docker & Services Web

Pour la gestion des services Docker (Traefik, Glances, Arcane, etc.) sur les hôtes Docker standards :

```bash
# Vérifier la connectivité des hôtes Docker
make ansible-ping

# Déployer tous les rôles
make ansible-deploy

# Déployer un rôle ciblé
make ansible-deploy TAGS="traefik"
```
