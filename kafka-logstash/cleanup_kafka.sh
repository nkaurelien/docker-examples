#!/bin/bash
# cleanup_kafka.sh - Script de nettoyage d'urgence

echo "=== NETTOYAGE D'URGENCE KAFKA STACK ==="

# Vérifier l'espace disque avant
echo "Espace disque AVANT :"
df -h /

# Arrêter le stack
echo "Arrêt du stack Kafka..."
cd /opt/docker/kafka
sudo docker-compose down

# Identifier et supprimer le conteneur problématique
echo "Suppression du conteneur logstash-storage..."
sudo docker container rm logstash-storage 2>/dev/null || true

# Nettoyer les données du conteneur problématique
echo "Nettoyage des données du conteneur..."
CONTAINER_ID="7f981c1dea829c257760479411f397534ee2d9f4ee24e1aaff2aac0ee0b79c27"
sudo rm -rf /var/lib/docker/containers/${CONTAINER_ID}* 2>/dev/null || true

# Nettoyer Docker
echo "Nettoyage Docker global..."
sudo docker system prune -f
sudo docker volume prune -f

# Vérifier l'espace après nettoyage
echo "Espace disque APRÈS nettoyage :"
df -h /

# Redémarrer le stack avec la nouvelle configuration
echo "Redémarrage du stack avec limitation des logs..."
sudo docker-compose up -d

echo "=== NETTOYAGE TERMINÉ ==="
echo "Vérifiez que tous les services sont UP avec : docker-compose ps"