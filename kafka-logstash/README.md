# Kafka Stack with Logstash - Production Ready

Ce projet déploie une infrastructure Kafka complète avec Logstash pour le traitement en temps réel des données EmotiBit.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Kafka Broker  │    │   Kafka Broker  │    │   Kafka Broker  │
│      (kafka1)   │    │      (kafka2)   │    │      (kafka3)   │
│     Port: 9092  │    │     Port: 9093  │    │     Port: 9094  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
         ┌───────────────────────┴───────────────────────┐
         │                 Zookeeper                     │
         │                Port: 2181                     │
         └───────────────────────┬───────────────────────┘
                                 │
    ┌──────────────┬─────────────┼─────────────┬──────────────┐
    │              │             │             │              │
┌───▼────┐  ┌─────▼─────┐  ┌────▼────┐  ┌────▼──────┐  ┌───▼────┐
│Logstash│  │ Logstash  │  │ Kafka   │  │   Kafka   │  │ Kafka  │
│(Index) │  │(Storage)  │  │   UI    │  │   Setup   │  │ Client │
│        │  │Port: 5045 │  │Port:8081│  │(Init only)│  │        │
└────────┘  └───────────┘  └─────────┘  └───────────┘  └────────┘
```

## 🔧 Services

| Service | Description | Ports | Rôle |
|---------|-------------|-------|------|
| **zookeeper** | Coordination Kafka | 2181 | Métadonnées cluster |
| **kafka1-3** | Brokers Kafka | 9092-9094 | Stockage/routage messages |
| **kafka-ui** | Interface web | 8081 | Monitoring/Administration |
| **logstash** | Pipeline indexation | - | Traitement données |
| **logstash-storage** | Pipeline stockage | 5045, 9601 | Stockage données |
| **kafka-setup** | Configuration initiale | - | Création topics |

## 📋 Prérequis

- Docker Engine 20.10+
- Docker Compose 2.0+
- Minimum 8GB RAM disponible
- 50GB espace disque libre (recommandé)

## 🚀 Installation et Démarrage

### 1. Cloner le projet
```bash
cd /opt/docker/kafka
```

### 2. Configuration des topics
Les topics suivants sont automatiquement créés :
- `Emotibit_rawdata` : Données brutes EmotiBit
- `Emotibit_processdata` : Données traitées EmotiBit

### 3. Démarrer le stack
```bash
# Démarrage complet
docker-compose up -d

# Vérifier le statut
docker-compose ps

# Voir les logs
docker-compose logs -f
```

### 4. Vérification
```bash
# Vérifier que Kafka est prêt
docker-compose logs kafka-setup

# Tester la connectivité
docker exec kafka1 kafka-topics --list --bootstrap-server localhost:9092
```

## 🔍 Monitoring et Administration

### Kafka UI
- **URL** : http://197.13.35.212:8081
- **Fonctionnalités** :
  - Visualisation des topics
  - Monitoring des partitions
  - Gestion des consumer groups
  - Métriques en temps réel

### Logstash Monitoring
```bash
# API Logstash Storage
curl http://197.13.35.212:9601/_node/stats

# Logs Logstash
docker-compose logs logstash-storage
```

### Métriques système
```bash
# Utilisation disque
df -h /

# Utilisation Docker
docker system df

# Conteneurs par utilisation espace
sudo du -h -d 1 /var/lib/docker/containers | sort -hr
```

## ⚠️ Gestion des Logs et Espace Disque

### Configuration de rotation des logs
Chaque service est configuré avec une rotation automatique :
- **Max size par fichier** : 10-100MB selon le service
- **Max fichiers conservés** : 2-3 fichiers
- **Total max par service** : 200-300MB

### Nettoyage d'urgence
```bash
# Script automatique
./cleanup_kafka.sh

# Commandes manuelles
docker-compose down
docker system prune -f
docker volume prune -f
docker-compose up -d
```

### Surveillance continue
```bash
# Monitoring en temps réel
watch "df -h / && docker-compose ps"

# Alert si > 90% d'utilisation
df / | awk 'NR==2 {if($5+0 > 90) print "ALERT: Disk usage " $5}'
```

## 🔧 Configuration Logstash

### Pipeline Index (`./pipeline_index/`)
Configuration pour l'indexation des données en temps réel.

### Pipeline Storage (`./pipeline_storage/`)
Configuration pour le stockage long terme des données.

### Variables d'environnement
```yaml
LS_JAVA_OPTS: "-Xmx2g -Xms2g -XX:+UseG1GC -XX:MaxGCPauseMillis=50"
PIPELINE_WORKERS: 1
PIPELINE_BATCH_SIZE: 1
PIPELINE_BATCH_DELAY: 1
```

## 🛠️ Commandes Utiles

### Gestion du Stack
```bash
# Arrêt
docker-compose down

# Redémarrage d'un service
docker-compose restart logstash-storage

# Logs spécifique
docker-compose logs -f kafka1

# Reconstruction
docker-compose down && docker-compose up -d --build
```

### Debug Kafka
```bash
# Lister les topics
docker exec kafka1 kafka-topics --list --bootstrap-server localhost:9092

# Détails d'un topic
docker exec kafka1 kafka-topics --describe --topic Emotibit_rawdata --bootstrap-server localhost:9092

# Consumer groups
docker exec kafka1 kafka-consumer-groups --list --bootstrap-server localhost:9092

# Écouter un topic
docker exec kafka1 kafka-console-consumer --topic Emotibit_rawdata --from-beginning --bootstrap-server localhost:9092
```

### Performance Tuning
```bash
# CPU et mémoire par conteneur
docker stats

# Threads Kafka
docker exec kafka1 ps aux | grep kafka

# Connectivité réseau
docker exec kafka1 netstat -tulpn
```

## 📊 Métriques de Performance

### Kafka Brokers
- **Throughput** : ~100k msg/sec par broker
- **Latency** : < 10ms p99
- **Replication Factor** : 3 (haute disponibilité)

### Logstash
- **Batch processing** : Optimisé pour temps réel
- **Memory** : 2GB par instance
- **Workers** : 1 (temps réel prioritaire)

## 🚨 Résolution de Problèmes

### Espace disque plein
```bash
# Diagnostic
sudo du -h -d 1 /var/lib/docker/containers | sort -hr

# Solution immédiate
docker-compose down
docker system prune -f
docker-compose up -d
```

### Kafka ne démarre pas
```bash
# Vérifier Zookeeper
docker-compose logs zookeeper

# Nettoyer les métadonnées
docker-compose down -v
docker-compose up -d
```

### Logstash en erreur
```bash
# Vérifier la configuration pipeline
docker-compose exec logstash-storage logstash --config.test_and_exit

# Logs détaillés
docker-compose logs logstash-storage | tail -100
```

## 📁 Structure du Projet

```
/opt/docker/kafka/
├── compose.yml                 # Configuration Docker Compose
├── pipeline_index/            # Configurations Logstash (indexation)
│   ├── input.conf
│   ├── filter.conf
│   └── output.conf
├── pipeline_storage/          # Configurations Logstash (stockage)
│   ├── input.conf
│   ├── filter.conf
│   └── output.conf
├── cleanup_kafka.sh           # Script de nettoyage
└── README.md                  # Cette documentation
```

## 🔒 Sécurité

### Réseau
- Communication interne via réseau Docker privé
- Exposition sélective des ports nécessaires
- Isolation des services par container

### Données
- Réplication 3x pour haute disponibilité
- Rétention configurable par topic
- Sauvegarde des configurations dans Git

## 📈 Scaling

### Horizontal
```bash
# Ajouter un broker
# 1. Ajouter kafka4 dans compose.yml
# 2. Redistribuer les partitions
docker exec kafka1 kafka-reassign-partitions --generate --bootstrap-server localhost:9092
```

### Vertical
```bash
# Augmenter la RAM Logstash
# Modifier LS_JAVA_OPTS dans compose.yml
LS_JAVA_OPTS: "-Xmx4g -Xms4g ..."
```

## 📞 Support

Pour toute question ou problème :
1. Vérifier les logs : `docker-compose logs`
2. Consulter les métriques : Kafka UI (port 8081)
3. Espace disque : `df -h /`
4. État des services : `docker-compose ps`

---

**Version** : 1.0  
**Dernière mise à jour** : Août 2025  
**Environnement** : data-to-innov-srv01