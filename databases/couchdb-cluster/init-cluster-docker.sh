#!/bin/sh

# Script d'initialisation du cluster CouchDB pour Docker
echo "Starting CouchDB cluster initialization..."

# Variables d'environnement
COORDINATOR_NODE="0"
ADDITIONAL_NODES="1 2"
BASE_URL="http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@couchdb-0:5984"

# Network configuration (can be overridden by environment variables)
NETWORK_SUBNET="${NETWORK_SUBNET:-172.19.0.0/24}"
NODE0_HOST="${NODE0_HOST:-couchdb-0}"
NODE1_HOST="${NODE1_HOST:-couchdb-1}"
NODE2_HOST="${NODE2_HOST:-couchdb-2}"

# Fonction pour attendre qu'un service soit prêt
wait_for_service() {
    local service=$1
    local max_attempts=30
    local attempt=1

    echo "Waiting for $service to be ready..."
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@${service}:5984/" > /dev/null; then
            echo "$service is ready!"
            return 0
        fi
        echo "Attempt $attempt/$max_attempts: $service not ready yet..."
        sleep 10
        attempt=$((attempt + 1))
    done

    echo "ERROR: $service failed to become ready after $max_attempts attempts"
    return 1
}

# Attendre que tous les services soient prêts
wait_for_service "${NODE0_HOST}"
wait_for_service "${NODE1_HOST}"
wait_for_service "${NODE2_HOST}"

echo "All CouchDB nodes are ready. Starting cluster setup..."

# Configuration du nœud coordinateur
echo "Setting up coordinator node: $COORDINATOR_NODE"
curl -X POST -H "Content-Type: application/json" "${BASE_URL}/_cluster_setup" \
  -d "{\"action\": \"enable_cluster\", \"bind_address\":\"0.0.0.0\", \"username\": \"${COUCHDB_USER}\", \"password\":\"${COUCHDB_PASSWORD}\", \"node_count\":\"3\"}"

echo ""
echo "You may safely ignore the 'Cluster is already enabled' warning above."

# Configuration des nœuds additionnels
for NODE_ID in $ADDITIONAL_NODES; do
  echo "Setting up additional node: $NODE_ID"

  # Activer le cluster sur le nœud distant avec le nom simple et l'IP
  NODE_HOST="couchdb-${NODE_ID}"
  echo "Enabling cluster on remote node: ${NODE_HOST}"
  
  curl -X POST -H "Content-Type: application/json" "${BASE_URL}/_cluster_setup" \
    -d "{\"action\": \"enable_cluster\", \"bind_address\":\"0.0.0.0\", \"username\": \"${COUCHDB_USER}\", \"password\":\"${COUCHDB_PASSWORD}\", \"port\": 5984, \"node_count\": \"3\", \"remote_node\": \"${NODE_HOST}\", \"remote_current_user\": \"${COUCHDB_USER}\", \"remote_current_password\": \"${COUCHDB_PASSWORD}\"}"

  echo ""

  # Ajouter le nœud au cluster avec le nom de nœud Erlang correct
  echo "Adding node to cluster: couchdb@${NODE_HOST}"
  curl -X POST -H "Content-Type: application/json" "${BASE_URL}/_cluster_setup" \
    -d "{\"action\": \"add_node\", \"host\":\"${NODE_HOST}\", \"port\": 5984, \"username\": \"${COUCHDB_USER}\", \"password\":\"${COUCHDB_PASSWORD}\", \"setup_type\":\"add_node\"}"

  echo ""
  sleep 5  # Attendre entre chaque ajout de nœud
done

# Finaliser la configuration du cluster
echo "Finalizing cluster setup..."
curl -X POST -H "Content-Type: application/json" "${BASE_URL}/_cluster_setup" \
  -d '{"action": "finish_cluster"}'

echo ""

# Vérifier le statut du cluster
echo "Checking cluster status..."
curl -s "${BASE_URL}/_cluster_setup" | grep -o '"state":"[^"]*"' || echo "Cluster setup completed"

echo ""

# Vérifier les membres du cluster
echo "Cluster membership:"
curl -s "${BASE_URL}/_membership"

echo ""
echo "Cluster initialization completed!"

# Get actual IP addresses from Docker
NODE0_IP=$(getent hosts ${NODE0_HOST} | awk '{ print $1 }')
NODE1_IP=$(getent hosts ${NODE1_HOST} | awk '{ print $1 }')
NODE2_IP=$(getent hosts ${NODE2_HOST} | awk '{ print $1 }')

echo "Access URLs:"
echo "- Node 0 (${NODE0_HOST}): http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@${NODE0_IP:-${NODE0_HOST}}:5984"
echo "- Node 1 (${NODE1_HOST}): http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@${NODE1_IP:-${NODE1_HOST}}:5984"
echo "- Node 2 (${NODE2_HOST}): http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@${NODE2_IP:-${NODE2_HOST}}:5984"