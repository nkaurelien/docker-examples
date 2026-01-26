# CouchDB Cluster Troubleshooting Guide

Ce guide documente les problèmes courants du cluster CouchDB et leurs solutions.

## Table des matières

- [Diagnostic rapide](#diagnostic-rapide)
- [Maintenance préventive](#maintenance-préventive)
- [Problème 1: Erreurs d'écriture 500 (internal_server_error)](#problème-1-erreurs-décriture-500-internal_server_error)
- [Problème 2: Nœuds manquants dans le cluster](#problème-2-nœuds-manquants-dans-le-cluster)
- [Problème 3: Espace disque insuffisant](#problème-3-espace-disque-insuffisant)
- [Commandes utiles](#commandes-utiles)

---

## Diagnostic rapide

### Vérifier l'état du cluster

```bash
# Membership du cluster (doit montrer tous les nœuds dans all_nodes ET cluster_nodes)
curl -s 'http://USER:PASS@localhost:PORT/_membership'

# État de santé de chaque nœud
curl -s 'http://USER:PASS@localhost:10100/' # Node 0
curl -s 'http://USER:PASS@localhost:10101/' # Node 1
curl -s 'http://USER:PASS@localhost:10102/' # Node 2
```

### Vérifier la configuration d'une base

```bash
# Voir les paramètres de quorum (q, n, w, r)
curl -s 'http://USER:PASS@localhost:PORT/DATABASE_NAME'
```

**Paramètres de quorum importants:**
- `q` : Nombre de shards
- `n` : Nombre de réplicas
- `w` : Nombre de nœuds requis pour une écriture (write quorum)
- `r` : Nombre de nœuds requis pour une lecture (read quorum)

---

## Maintenance préventive

### Nettoyage des images Docker (À FAIRE AVANT CHAQUE DÉPLOIEMENT)

Les anciennes images Docker s'accumulent et peuvent remplir le disque. **Exécuter ce nettoyage avant chaque déploiement.**

#### Script de nettoyage pré-déploiement

```bash
#!/bin/bash
# Script: pre-deploy-cleanup.sh
# À exécuter AVANT chaque déploiement sur les serveurs

echo "=== Vérification espace disque AVANT nettoyage ==="
df -h / | grep -v Filesystem

echo ""
echo "=== Utilisation Docker ==="
docker system df

echo ""
echo "=== Nettoyage des images non utilisées (>30 jours) ==="
docker image prune -a -f --filter 'until=720h'

echo ""
echo "=== Nettoyage du cache de build ==="
docker builder prune -f

echo ""
echo "=== Vérification espace disque APRÈS nettoyage ==="
df -h / | grep -v Filesystem
docker system df
```

#### Intégration dans le processus de déploiement

**Option 1: Makefile (recommandé)**

Ajouter au Makefile principal :

```makefile
# Nettoyage pré-déploiement
pre-deploy-cleanup:
	@echo "Nettoyage des images Docker non utilisées..."
	docker image prune -a -f --filter 'until=720h'
	docker builder prune -f
	@echo "Nettoyage terminé"

# Déploiement avec nettoyage
deploy-prod-tn-safe: pre-deploy-cleanup deploy-prod-tn

deploy-staging-tn-safe: pre-deploy-cleanup deploy-staging-tn
```

**Option 2: Ansible (pour déploiements automatisés)**

Ajouter une tâche dans le playbook de déploiement :

```yaml
- name: Cleanup old Docker images before deployment
  community.docker.docker_prune:
    images: yes
    images_filters:
      dangling: false
      until: 720h
    builder_cache: yes
  tags: [cleanup, deploy]
```

**Option 3: Cron job (maintenance automatique)**

Ajouter un cron job hebdomadaire sur chaque serveur :

```bash
# Éditer crontab
crontab -e

# Ajouter (nettoyage tous les dimanches à 3h du matin)
0 3 * * 0 docker image prune -a -f --filter 'until=720h' && docker builder prune -f >> /var/log/docker-cleanup.log 2>&1
```

### Surveillance de l'espace disque

Configurer une alerte si le disque dépasse 80% :

```bash
# Script de monitoring (à ajouter dans cron)
THRESHOLD=80
USAGE=$(df / | grep -v Filesystem | awk '{print $5}' | sed 's/%//')

if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "ALERTE: Disque à ${USAGE}% - Nettoyage requis" | mail -s "Alerte disque serveur" admin@example.com
fi
```

### Checklist de déploiement

Avant chaque déploiement :

- [ ] Vérifier l'espace disque (`df -h`)
- [ ] Exécuter le nettoyage Docker si > 70% utilisé
- [ ] Vérifier le cluster CouchDB (`_membership`)
- [ ] Déployer
- [ ] Vérifier les logs après déploiement

---

## Problème 1: Erreurs d'écriture 500 (internal_server_error)

### Symptômes

- Erreurs Sentry : `Error saving job metrics: (500, ('error', 'internal_server_error'))`
- Les écritures dans CouchDB échouent
- Les lectures fonctionnent parfois

### Causes possibles

1. **Espace disque insuffisant** (`enospc`)
2. **Quorum non satisfait** (pas assez de nœuds disponibles pour `w`)
3. **Nœuds déconnectés du cluster**

### Diagnostic

```bash
# 1. Vérifier l'espace disque
df -h /

# 2. Vérifier la membership
curl -s 'http://USER:PASS@localhost:PORT/_membership'

# 3. Comparer all_nodes vs cluster_nodes
# - all_nodes : nœuds actuellement connectés
# - cluster_nodes : nœuds configurés dans le cluster
# Si all_nodes < w (write quorum), les écritures échoueront
```

### Solution

Voir les sections suivantes selon la cause identifiée.

---

## Problème 2: Nœuds manquants dans le cluster

### Symptômes

```json
{
  "all_nodes": ["couchdb@couchdb-0.cluster"],
  "cluster_nodes": ["couchdb@couchdb-0.cluster", "couchdb@couchdb-1.cluster", "couchdb@couchdb-2.cluster"]
}
```

`all_nodes` contient moins de nœuds que `cluster_nodes`.

### Cause principale: Mismatch hostname/NODENAME

Les nœuds Erlang utilisent le NODENAME pour communiquer. Si le hostname du container ne correspond pas au NODENAME, les nœuds ne peuvent pas se résoudre entre eux.

### Diagnostic

```bash
# Vérifier le hostname de chaque container
docker compose exec -T couchdb-0 hostname
docker compose exec -T couchdb-1 hostname
docker compose exec -T couchdb-2 hostname

# Vérifier le NODENAME configuré
docker compose exec -T couchdb-0 cat /opt/couchdb/etc/vm.args | grep -E '^-name'
```

**Le hostname doit correspondre au NODENAME !**

Exemple correct:
- Hostname: `couchdb-0.asone4health-couchdb`
- NODENAME: `couchdb@couchdb-0.asone4health-couchdb`

### Solution

1. **Ajouter `hostname` dans docker-compose.yml pour chaque service CouchDB:**

```yaml
services:
  couchdb-0:
    hostname: couchdb-0.${COUCHDB_NODE_NAME:-couchdb-cluster}
    environment:
      NODENAME: couchdb-0.${COUCHDB_NODE_NAME:-couchdb-cluster}
      # ...
```

2. **Recréer les containers:**

```bash
docker compose up -d --force-recreate couchdb-0 couchdb-1 couchdb-2
```

3. **Vérifier la membership après redémarrage:**

```bash
# Attendre 20 secondes puis vérifier
sleep 20
curl -s 'http://USER:PASS@localhost:PORT/_membership'
```

### Si les nœuds sont toujours déconnectés

Supprimer manuellement les nœuds mal configurés et les réajouter:

```bash
# 1. Obtenir la révision du nœud mal nommé
curl -s 'http://USER:PASS@localhost:PORT/_node/_local/_nodes/couchdb@WRONG_NAME'

# 2. Supprimer avec la révision
curl -X DELETE 'http://USER:PASS@localhost:PORT/_node/_local/_nodes/couchdb@WRONG_NAME?rev=REV_ID'

# 3. Ajouter le nœud avec le bon nom
curl -X PUT 'http://USER:PASS@localhost:PORT/_node/_local/_nodes/couchdb@CORRECT_NAME' -d '{}'
```

---

## Problème 3: Espace disque insuffisant

### Symptômes

- Erreur `enospc` dans les logs
- `df -h` montre le disque à 100%

### Diagnostic

```bash
# Vérifier l'espace disque
df -h /

# Vérifier l'utilisation Docker
docker system df
```

### Solution

1. **Nettoyer les images Docker non utilisées:**

```bash
# Supprimer les images de plus de 30 jours non utilisées
docker image prune -a -f --filter 'until=720h'
```

2. **Nettoyer le cache de build:**

```bash
docker builder prune -f
```

3. **Lister les volumes non utilisés (ATTENTION - ne pas supprimer sans vérifier):**

```bash
# Lister seulement
docker volume ls -f dangling=true

# Supprimer (DANGER - vérifier d'abord !)
# docker volume prune -f
```

4. **Vérifier après nettoyage:**

```bash
df -h /
docker system df
```

---

## Commandes utiles

### Gestion du cluster

```bash
# État du cluster setup
curl -s 'http://USER:PASS@localhost:PORT/_cluster_setup'

# Forcer la finalisation du cluster
curl -X POST 'http://USER:PASS@localhost:PORT/_cluster_setup' \
  -H 'Content-Type: application/json' \
  -d '{"action": "finish_cluster"}'
```

### Test d'écriture

```bash
# Tester une écriture
curl -X PUT 'http://USER:PASS@localhost:PORT/DATABASE/test_doc_$(date +%s)' \
  -H 'Content-Type: application/json' \
  -d '{"test": "write_test", "timestamp": "'$(date -Iseconds)'"}'
```

### Logs des containers

```bash
# Voir les logs CouchDB
docker compose logs -f couchdb-0 couchdb-1 couchdb-2

# Logs d'un seul nœud
docker compose logs -f couchdb-0 --tail=100
```

### Redémarrage du cluster

```bash
# Redémarrage gracieux (recommandé)
docker compose restart couchdb-0 couchdb-1 couchdb-2

# Recréation complète (si nécessaire)
docker compose up -d --force-recreate couchdb-0 couchdb-1 couchdb-2
```

---

## Checklist de résolution

- [ ] Vérifier l'espace disque (`df -h`)
- [ ] Vérifier la membership (`_membership`)
- [ ] Comparer `all_nodes` vs `cluster_nodes`
- [ ] Vérifier les hostnames des containers
- [ ] Vérifier que NODENAME correspond au hostname
- [ ] Tester une écriture après correction
- [ ] Vérifier les logs pour confirmer l'absence d'erreurs

---

## Historique des incidents

### Janvier 2026 - Serveur TN

**Problème:** Erreurs Sentry PYTHON-FASTAPI-D2 et PYTHON-FASTAPI-4Q - échec d'écriture dans la base metrics.

**Causes:**
1. Disque plein à 100% (images Docker)
2. Cluster avec 1 seul nœud disponible sur 3 (hostname manquant)

**Solutions:**
1. Nettoyage de 199.8 GB d'images Docker non utilisées
2. Ajout de `hostname` dans docker-compose.yml
3. Recréation des containers

**Temps de résolution:** ~30 minutes
