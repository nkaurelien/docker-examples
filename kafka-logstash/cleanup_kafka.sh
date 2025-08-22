#!/bin/bash
# cleanup_kafka.sh - Script de nettoyage d'urgence

echo "=== NETTOYAGE D'URGENCE KAFKA STACK ==="

# Vérifier l'espace disque avant
echo "Espace disque AVANT :"
df -h /

# Arrêter le stack
echo "Arrêt du stack Kafka..."
# Note: Adjust the path to your kafka-logstash directory
cd $(dirname "$0")
docker-compose down

# Identifier et supprimer les conteneurs problématiques
echo "Suppression des conteneurs Kafka/Logstash..."
docker container rm logstash-storage 2>/dev/null || true
docker container rm logstash 2>/dev/null || true

# Nettoyer Docker
echo "Nettoyage Docker global..."
docker system prune -f
docker volume prune -f

# Vérifier l'espace après nettoyage
echo "Espace disque APRÈS nettoyage :"
df -h /

# Redémarrer le stack avec la nouvelle configuration
echo "Redémarrage du stack avec limitation des logs..."
docker-compose up -d

echo "=== NETTOYAGE TERMINÉ ==="
echo "Vérifiez que tous les services sont UP avec : docker-compose ps"