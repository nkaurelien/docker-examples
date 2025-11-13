#!/bin/bash
# MySQL Database Export Script
# This script exports the WordPress database with timestamp

set -e

# Configuration from environment variables or defaults
MYSQL_HOST="${MYSQL_HOST:-db}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-secret}"
MYSQL_DATABASE="${MYSQL_DATABASE:-wordpress}"
BACKUP_DIR="${BACKUP_DIR:-/dumps}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"

# Generate timestamp
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
DATE_ONLY=$(date +%Y-%m-%d)

# Backup files
FULL_BACKUP="${BACKUP_DIR}/wordpress_${TIMESTAMP}.sql.gz"
SCHEMA_BACKUP="${BACKUP_DIR}/wordpress_schema_${DATE_ONLY}.sql"
LATEST_LINK="${BACKUP_DIR}/wordpress_latest.sql.gz"

echo "=========================================="
echo "MySQL Database Export"
echo "=========================================="
echo "Date: $(date)"
echo "Host: ${MYSQL_HOST}:${MYSQL_PORT}"
echo "Database: ${MYSQL_DATABASE}"
echo "Backup Directory: ${BACKUP_DIR}"
echo "Retention: ${RETENTION_DAYS} days"
echo "=========================================="

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
for i in {1..30}; do
    if mysqladmin ping -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -uroot -p"${MYSQL_ROOT_PASSWORD}" --silent 2>/dev/null; then
        echo "✓ MySQL is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "✗ Error: MySQL is not responding after 30 seconds"
        exit 1
    fi
    sleep 1
done

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Export full database (compressed)
echo ""
echo "Exporting full database..."
if mysqldump -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -uroot -p"${MYSQL_ROOT_PASSWORD}" \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    --databases "${MYSQL_DATABASE}" 2>/dev/null | gzip > "${FULL_BACKUP}"; then

    BACKUP_SIZE=$(du -h "${FULL_BACKUP}" | cut -f1)
    echo "✓ Full backup created: ${FULL_BACKUP} (${BACKUP_SIZE})"

    # Create/update 'latest' symlink
    ln -sf "$(basename "${FULL_BACKUP}")" "${LATEST_LINK}"
    echo "✓ Latest backup link updated"
else
    echo "✗ Error: Full backup failed"
    exit 1
fi

# Export schema only (daily, not timestamped to avoid duplicates)
echo ""
echo "Exporting database schema..."
if mysqldump -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -uroot -p"${MYSQL_ROOT_PASSWORD}" \
    --no-data \
    --routines \
    --triggers \
    --events \
    --databases "${MYSQL_DATABASE}" > "${SCHEMA_BACKUP}" 2>/dev/null; then

    SCHEMA_SIZE=$(du -h "${SCHEMA_BACKUP}" | cut -f1)
    echo "✓ Schema backup created: ${SCHEMA_BACKUP} (${SCHEMA_SIZE})"
else
    echo "✗ Error: Schema backup failed"
    exit 1
fi

# Cleanup old backups (keep only last N days)
echo ""
echo "Cleaning up old backups (keeping ${RETENTION_DAYS} days)..."
DELETED_COUNT=0

# Find and delete old full backups
find "${BACKUP_DIR}" -name "wordpress_*.sql.gz" -type f -mtime +${RETENTION_DAYS} -print0 | while IFS= read -r -d '' file; do
    if [ -f "$file" ]; then
        echo "  Deleting: $(basename "$file")"
        rm -f "$file"
        DELETED_COUNT=$((DELETED_COUNT + 1))
    fi
done

# Find and delete old schema backups
find "${BACKUP_DIR}" -name "wordpress_schema_*.sql" -type f -mtime +${RETENTION_DAYS} -print0 | while IFS= read -r -d '' file; do
    if [ -f "$file" ]; then
        echo "  Deleting: $(basename "$file")"
        rm -f "$file"
    fi
done

if [ $DELETED_COUNT -eq 0 ]; then
    echo "✓ No old backups to delete"
else
    echo "✓ Deleted $DELETED_COUNT old backup(s)"
fi

# Summary
echo ""
echo "=========================================="
echo "Backup Summary"
echo "=========================================="
echo "Available backups:"
ls -lh "${BACKUP_DIR}"/wordpress_*.sql.gz 2>/dev/null | tail -5 || echo "  No backups found"
echo ""
TOTAL_SIZE=$(du -sh "${BACKUP_DIR}" | cut -f1)
BACKUP_COUNT=$(find "${BACKUP_DIR}" -name "wordpress_*.sql.gz" -type f | wc -l | tr -d ' ')
echo "Total backups: ${BACKUP_COUNT}"
echo "Total size: ${TOTAL_SIZE}"
echo "=========================================="
echo "✓ Backup completed successfully"
echo "=========================================="
