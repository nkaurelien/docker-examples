#!/bin/bash
set -e

echo "Waiting for Arcane database to initialize..."
# Wait up to 30 seconds for the database file to be created
for i in {1..30}; do
  if docker run --rm -v arcane-data:/data alpine test -f /data/arcane.db; then
    echo "Arcane database found!"
    break
  fi
  if [ $i -eq 30 ]; then
    echo "Error: Arcane database not initialized in time."
    exit 1
  fi
  sleep 1
done

echo "Registering arcane-registry.json in the database..."
docker run --rm -v arcane-data:/data alpine sh -c "
  apk add --no-cache -q sqlite && \
  sqlite3 /data/arcane.db \"INSERT OR IGNORE INTO template_registries (id, name, url, enabled, description) VALUES (
    'nkaurelien-docker-examples', 
    'nkaurelien Docker Examples', 
    'https://nkaurelien.github.io/docker-examples/arcane-registry.json', 
    1, 
    'Collection of production-ready Docker Compose templates'
  );\"
"

echo "Template registry registered successfully!"
