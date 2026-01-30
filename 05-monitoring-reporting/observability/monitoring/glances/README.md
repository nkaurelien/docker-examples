# Glances

Glances est un outil de monitoring système cross-platform écrit en Python.

## Versions disponibles

- `compose.yml` : Version standard avec accès direct au docker.sock
- `compose.socket-proxy.yml` : Version sécurisée avec docker-socket-proxy

## Démarrage

### Version standard
```bash
docker compose up -d
```
Accès via http://localhost:61208

### Version sécurisée (socket-proxy)
```bash
docker compose -f compose.socket-proxy.yml up -d
```
Accès via http://localhost:61208

## Limitations Docker

> **Important** : Glances dans Docker a des limitations pour le monitoring des processus du host.

### Pourquoi ?
Même avec `pid: host` et `privileged: true`, Docker isole partiellement le conteneur du système hôte. Sur **macOS/Windows avec Docker Desktop**, Docker tourne dans une VM Linux, donc les processus natifs du système hôte ne sont pas visibles.

### Solutions alternatives

1. **Installation native sur le host** (recommandé pour monitoring complet) :
```bash
# Linux/macOS
pip install glances[web]
glances -w

# ou avec brew sur macOS
brew install glances
glances -w
```

2. **Utiliser la version Docker pour le monitoring des conteneurs uniquement** :
   - Les conteneurs Docker seront bien monitorés
   - Les métriques système (CPU, RAM, disque) seront celles de la VM Docker

3. **Sur Linux natif** : La version Docker fonctionne mieux car pas de VM intermédiaire

## Configuration

### Variables d'environnement

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `TZ` | Fuseau horaire | `Europe/Paris` |
| `GLANCES_OPT` | Options Glances | `-w` (mode web) |
| `DOCKER_HOST` | Endpoint Docker (socket-proxy) | `tcp://socket-proxy:2375` |
| `GLANCES_PROC_PATH` | Chemin vers /proc du host | `/host/proc` |
| `GLANCES_SYS_PATH` | Chemin vers /sys du host | `/host/sys` |

### Options Glances courantes

- `-w` : Mode serveur web
- `-s` : Mode serveur
- `-c <server>` : Mode client
- `--process-short-name` : Noms de processus courts
- `--export influxdb` : Export vers InfluxDB
- `--export prometheus` : Export vers Prometheus

## Ports

| Port | Description |
|------|-------------|
| 61208 | Interface Web |
| 61209 | API REST |

## Permissions socket-proxy

La version socket-proxy utilise des permissions minimales :
- `CONTAINERS=1` : Lister les conteneurs
- `IMAGES=1` : Lister les images
- `INFO=1` : Informations Docker
- `NETWORKS=1` : Statistiques réseau
- `SYSTEM=1` : Informations système
- `VOLUMES=1` : Statistiques volumes
- `EVENTS=1` : Événements en temps réel

## Ressources

- [Documentation officielle](https://glances.readthedocs.io/)
- [GitHub](https://github.com/nicolargo/glances)
- [Docker Hub](https://hub.docker.com/r/nicolargo/glances)
