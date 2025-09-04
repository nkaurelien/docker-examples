#!/bin/bash

# CouchDB Cluster Test Script
echo "🧪 Testing CouchDB Cluster Setup..."
echo ""

# Load environment variables
source .env

# Test function
test_endpoint() {
    local url=$1
    local name=$2
    
    echo -n "Testing $name... "
    if curl -s -f "$url" > /dev/null; then
        echo "✅ OK"
    else
        echo "❌ FAILED"
        return 1
    fi
}

echo "📡 Testing CouchDB Endpoints:"
test_endpoint "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@localhost:$((PORT_BASE + 0))/" "Node 0"
test_endpoint "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@localhost:$((PORT_BASE + 1))/" "Node 1"  
test_endpoint "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@localhost:$((PORT_BASE + 2))/" "Node 2"

echo ""
echo "🔗 Testing Cluster Membership:"
curl -s "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@localhost:$((PORT_BASE + 0))/_membership" | jq -r '"Cluster nodes: " + (.cluster_nodes | length | tostring)'

echo ""
echo "🎯 Testing Database Creation:"
DB_NAME="test-$(date +%s)"
echo "Creating test database: $DB_NAME"

if curl -s -X PUT "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@localhost:$((PORT_BASE + 0))/$DB_NAME" > /dev/null; then
    echo "✅ Database created successfully"
    
    echo "Checking replication across nodes..."
    sleep 2
    
    for i in 0 1 2; do
        port=$((PORT_BASE + i))
        if curl -s "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@localhost:${port}/$DB_NAME" | grep -q "db_name"; then
            echo "✅ Node $i has the database"
        else
            echo "❌ Node $i missing the database"
        fi
    done
    
    # Cleanup
    echo "Cleaning up test database..."
    curl -s -X DELETE "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@localhost:$((PORT_BASE + 0))/$DB_NAME" > /dev/null
    echo "🧹 Cleanup completed"
else
    echo "❌ Failed to create test database"
fi

echo ""
echo "🎉 Cluster test completed!"