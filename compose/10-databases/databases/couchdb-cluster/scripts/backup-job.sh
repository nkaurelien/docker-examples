#!/bin/bash

# CouchDB Backup Job for Ofelia
# Simplified backup script for job execution

set -e

# Configuration
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/backups/ofelia_backup_${TIMESTAMP}"
LOG_FILE="/opt/backups/backup_${TIMESTAMP}.log"
BACKUP_SCRIPT="/opt/manage/backup_restore_couchdb.sh"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

# Create backup directory
mkdir -p "${BACKUP_DIR}"

log "=== CouchDB Backup Job Started ==="
log "Backup directory: ${BACKUP_DIR}"

# Check if backup script exists
if [ ! -f "${BACKUP_SCRIPT}" ]; then
    log "✗ Backup script not found at ${BACKUP_SCRIPT}"
    exit 1
fi

# Copy script to temp location to make it executable
cp "${BACKUP_SCRIPT}" "/tmp/backup_restore_couchdb.sh"
chmod +x "/tmp/backup_restore_couchdb.sh"
BACKUP_SCRIPT="/tmp/backup_restore_couchdb.sh"

# CouchDB connection details (connect to cluster node 0)
COUCHDB_HOST="couchdb-0"
COUCHDB_PORT="5984"
COUCHDB_USER="${COUCHDB_USER:-admin}"
COUCHDB_PASS="${COUCHDB_PASSWORD:-admin}"

log "Connecting to CouchDB at ${COUCHDB_HOST}:${COUCHDB_PORT}"

# Install required tools if not available
if ! command -v jq >/dev/null 2>&1; then
    log "Installing required tools..."
    apt-get update && apt-get install -y jq curl >/dev/null 2>&1
fi

# Get list of all databases (excluding system databases)
log "Getting database list..."
databases=$(curl -s -u "${COUCHDB_USER}:${COUCHDB_PASS}" \
    "http://${COUCHDB_HOST}:${COUCHDB_PORT}/_all_dbs" | \
    jq -r '.[] | select(startswith("_") | not)' 2>/dev/null)

if [ -z "$databases" ]; then
    log "No user databases found"
    exit 0
fi

log "Found databases: $(echo $databases | tr '\n' ' ')"

success_count=0
total_count=0

# Backup each database using the existing script
for db_name in $databases; do
    total_count=$((total_count + 1))
    log "Backing up database: ${db_name}"
    
    if bash "${BACKUP_SCRIPT}" -b -H "${COUCHDB_HOST}" -P "${COUCHDB_PORT}" \
        -u "${COUCHDB_USER}" -p "${COUCHDB_PASS}" -d "${db_name}" -o "${BACKUP_DIR}" -q 2>/dev/null; then
        log "✓ Successfully backed up: ${db_name}"
        success_count=$((success_count + 1))
    else
        log "✗ Failed to backup: ${db_name}"
    fi
done

log "Backup completed: ${success_count}/${total_count} databases backed up successfully"
log "Backup location: ${BACKUP_DIR}"

# Show backup directory size
if [ -d "${BACKUP_DIR}" ]; then
    backup_size=$(du -sh "${BACKUP_DIR}" 2>/dev/null | cut -f1 || echo "unknown")
    file_count=$(find "${BACKUP_DIR}" -type f -name "*.json" 2>/dev/null | wc -l)
    log "Backup size: ${backup_size} (${file_count} files)"
fi

# Cleanup old backups (keep last N days)
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-7}
log "Cleaning up backups older than ${RETENTION_DAYS} days..."

find /opt/backups -name "ofelia_backup_*" -type d -mtime +${RETENTION_DAYS} -exec rm -rf {} \; 2>/dev/null || true
find /opt/backups -name "backup_*.log" -mtime +${RETENTION_DAYS} -delete 2>/dev/null || true

log "Cleanup completed"
log "=== CouchDB Backup Job Finished ==="

# Exit with success
exit 0