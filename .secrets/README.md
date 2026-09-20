# 🔐 Registre des Secrets & Identifiants Homelab

Ce dossier `.secrets/` est ignoré par Git (via `.gitignore` : `.secrets/*`, excepté les fichiers `.md` sans valeurs sensibles ou ce guide).

---

## 📋 Répertoire des Accès et Tokens

### 1. Headlamp (Dashboard Kubernetes)
- **URL** : `https://headlamp.kamitbrains-minipc-k1.lab`
- **Méthode** : Token Bearer (ServiceAccount `headlamp` avec ClusterRole `cluster-admin`)
- **Fichier du Token** : `.secrets/headlamp-token.txt`
- **Commande de régénération si expiré** :
  ```bash
  kubectl --context k3s-ansible -n headlamp create token headlamp --duration=8760h
  ```

---

### 2. Rancher Server
- **URL** : `https://rancher.kamitbrains-minipc-k1.lab`
- **Utilisateur initial** : `admin`
- **Bootstrap Password initial** : `admin`
- **Fichier des identifiants** : `.secrets/rancher-credentials.txt`

---

### 3. Databases (Namespace `databases`)

#### A. Apache CouchDB 3.4
- **URL Web (Fauxton)** : `https://couchdb.kamitbrains-minipc-k1.lab`
- **Utilisateur** : `admin`
- **Mot de passe par défaut** : `couchdb_secure_password`
- **Secret Erlang** : `couchdb_homelab_secret_key`
- **Fichier** : `.secrets/couchdb.env`

#### B. PostgreSQL 16 (Interne)
- **Service DNS interne** : `postgres.databases.svc.cluster.local:5432`
- **Utilisateur** : `postgres`
- **Mot de passe par défaut** : `postgres_secure_password`
- **Base par défaut** : `homelab`
- **Fichier** : `.secrets/postgres.env`

---

### 4. Monitoring (Namespace `monitoring`)

#### Umami Analytics
- **URL Web** : `https://analytics.kamitbrains-minipc-k1.lab`
- **Base de données dédiée** : `umami-db.monitoring.svc.cluster.local:5432` (user `umami` / pass `umami_secure_password`)
- **Compte Administrateur Umami initial** :
  - **Login** : `admin`
  - **Mot de passe** : `umami`
- **Fichier** : `.secrets/umami.env`

---

### 5. Services IA & Speech-To-Text (Namespace `ai`)

#### Faster-Whisper (Wyoming STT)
- **Service TCP interne** : `faster-whisper.ai.svc.cluster.local:10300`
- **Protocole** : Wyoming (binaire, sans authentification par défaut, restreint au réseau interne du cluster).
