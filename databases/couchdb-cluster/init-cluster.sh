#!/bin/bash


# Run command (example)
# COMPOSE_PROJECT_NAME=your-project PORT_BASE=5984 COUCHDB_USER=admin COUCHDB_PASSWORD=your-password bash init-cluster.sh 


# Load environment variables from .env file
source .env

# Print environment variables for debugging
echo "COUCHDB_USER: $COUCHDB_USER"
echo "COUCHDB_PASSWORD: $COUCHDB_PASSWORD"
echo "PORT_BASE: $PORT_BASE"
echo "COMPOSE_PROJECT_NAME: $COMPOSE_PROJECT_NAME"

DEPLOYMENT_NAME=${COMPOSE_PROJECT_NAME}
IFS=","
COORDINATOR_NODE="0"
ADDITIONAL_NODES="1,2"
ALL_NODES="${COORDINATOR_NODE},${ADDITIONAL_NODES}"

# Print deployment and node information for debugging
echo "DEPLOYMENT_NAME: $DEPLOYMENT_NAME"
echo "COORDINATOR_NODE: $COORDINATOR_NODE"
echo "ADDITIONAL_NODES: $ADDITIONAL_NODES"
echo "ALL_NODES: $ALL_NODES"

# Cluster setup for coordinator node
for NODE_ID in $COORDINATOR_NODE
do
  echo "Setting up coordinator node: $NODE_ID"
  curl -X POST -H "Content-Type: application/json" "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@127.0.0.1:${PORT_BASE}${NODE_ID}/_cluster_setup" \
  -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "'"${COUCHDB_USER}"'", "password":"'"${COUCHDB_PASSWORD}"'", "node_count":"3"}'
  echo "You may safely ignore the warning above."
done

# Cluster setup for additional nodes
for NODE_ID in $ADDITIONAL_NODES
do
  echo "Setting up additional node: $NODE_ID"
  curl -X POST -H "Content-Type: application/json" "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@127.0.0.1:${PORT_BASE}0/_cluster_setup" -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "'"${COUCHDB_USER}"'", "password":"'"${COUCHDB_PASSWORD}"'", "port": 5984, "node_count": "3", "remote_node": "'"couchdb-${NODE_ID}.${DEPLOYMENT_NAME}"'", "remote_current_user": "'"${COUCHDB_USER}"'", "remote_current_password": "'"${COUCHDB_PASSWORD}"'" }'
  curl -X POST -H "Content-Type: application/json" "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@127.0.0.1:${PORT_BASE}0/_cluster_setup" -d '{"action": "add_node", "host":"'"couchdb-${NODE_ID}.${DEPLOYMENT_NAME}"'", "port": 5984, "username": "'"${COUCHDB_USER}"'", "password":"'"${COUCHDB_PASSWORD}"'"}'
done

# Finish cluster setup
curl "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@127.0.0.1:${PORT_BASE}0/"
curl -X POST -H "Content-Type: application/json" "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@127.0.0.1:${PORT_BASE}0/_cluster_setup" -d '{"action": "finish_cluster"}'
curl "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@127.0.0.1:${PORT_BASE}0/_cluster_setup"
curl "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@127.0.0.1:${PORT_BASE}0/_membership"

# Print cluster node URLs
echo "Your cluster nodes are available at:"
for NODE_ID in ${ALL_NODES}
do
  echo "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@localhost:${PORT_BASE}${NODE_ID}"
done
