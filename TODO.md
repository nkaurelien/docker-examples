# TODO — Implémentations partielles des articles de blog

Articles du blog ([nkaurelien.github.io](https://github.com/nkaurelien/nkaurelien.github.io), `datasources/articles/`) dont l'implémentation dans ce dépôt ne couvre qu'une partie du contenu.

Quand un article est entièrement couvert :
1. ajouter en haut de l'article l'encadré « 💻 Code source » (lien vers le dossier + `git clone` / `cd`) ;
2. ajouter la section `### Code source` en fin d'article ;
3. retirer l'entrée de ce fichier.

Articles déjà liés : OpenLDAP, Architecture Homelab, Analytics Umami, Kustomize base & overlays, FastAPI anti-pattern Gunicorn.

---

## 🟡 À compléter

### Le Socket Docker : proxy et moindre privilège
- **Article** : `2026-09-20-securiser-socket-docker-proxy-moindre-privilege.md`
- **Existe** : `ansible/roles/docker-socket-proxy` (`tecnativa/docker-socket-proxy`, permissions `POST`/`EXEC`, réseau `internal: true`), `compose/01-infrastructure/traefik/compose.socket-proxy.yml`
- **Manque** — section « Durcir le proxy lui-même » :
  - [ ] `read_only: true` + `tmpfs` sur le proxy
  - [ ] `cap_drop: [ALL]` (+ `cap_add` minimal si nécessaire)
  - [ ] `security_opt: [no-new-privileges:true]`
  - [ ] Appliquer aussi dans `compose.socket-proxy.yml` / `compose.*.socket-proxy.yml`

### Builder et promouvoir des images dans Kubernetes : Kaniko + Crane
- **Article** : `2026-09-20-build-images-kubernetes-kaniko-crane.md`
- **Existe** : `kubernetes/infrastructure/ci-cd/kaniko` (job template + secret template)
- **Manque** :
  - [ ] Job / exemple de promotion avec Crane (`crane copy` entre registries ou tags)
  - [ ] Enchaînement build Kaniko → promotion Crane documenté dans le README

### Cluster K3s air-gap : Rancher, Infisical, Valkey, Faster-Whisper
- **Article** : `2026-09-20-cluster-k3s-rancher-infisical-valkey-faster-whisper.md`
- **Existe** : playbooks `ansible/k3s-*.yml`, `ansible/scripts/prepare-airgap.sh`, `kubernetes/apps/security/infisical.yaml`, `kubernetes/apps/ai/faster-whisper.yaml`, rôles `ansible/roles/{infisical,faster-whisper}`
- **Manque** :
  - [ ] Déploiement Rancher sur K3s (aujourd'hui uniquement dans `docs/services/orchestration`)
  - [ ] Manifeste Valkey pour K3s (`kubernetes/apps/databases/valkey.yaml`) — Valkey n'existe qu'en Compose (`compose/10-databases/databases`)

### Sauvegardes : Restic, dumps et base vivante
- **Article** : `2026-09-20-sauvegardes-restic-dump-base-vivante-matrice-decision.md`
- **Existe** : `ansible/roles/backrest` (UI Restic), `docs/services/backups` (Backrest, Databasement)
- **Manque** :
  - [ ] Dump cohérent PostgreSQL (`pg_dump`) avant la sauvegarde Restic (job Ofelia ou hook Backrest)
  - [ ] Exemple de restauration testée
  - [ ] Matrice de décision de l'article reprise dans `docs/services/backups`

### Plateforme IoT santé FHIR/HL7
- **Article** : `2026-09-15-construire-une-plateforme-iot-sante-fhir-hl7.md`
- **Existe** : `compose/17-data-processing/kafka-logstash` (pipeline Emotibit), dépôt [`fhir-nextjs-starter`](https://github.com/nkaurelien/fhir-nextjs-starter) (2024)
- **Manque** :
  - [ ] Service FastAPI de conversion capteur → ressources FHIR
  - [ ] Diffusion temps réel WebSocket vers le front Next.js
  - [ ] Vérifier que `fhir-nextjs-starter` correspond encore à l'article (dernière mise à jour 2024-12)

### Assistant RAG sur +500 documents (LangChain, Ollama, LiteLLM)
- **Article** : `2026-09-15-transformer-500-documents-en-assistant-rag.md`
- **Existe** : dépôt [`ai-llm-python-playground`](https://github.com/nkaurelien/ai-llm-python-playground) (`langchain-*-simple-rag`), `compose/06-ai/ollama-local`
- **Manque** :
  - [ ] RAG avancé / agentique décrit dans l'article (le dépôt ne contient qu'un RAG simple)
  - [ ] Passerelle LiteLLM devant Ollama
  - [ ] Stockage vectoriel pgvector
