#!/bin/bash
# PostgreSQL Database Export Script
# This script exports PostgreSQL databases with timestamp

set -e

# Configuration from environment variables or defaults
POSTGRES_HOST="${POSTGRES_HOST:-postgres}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-postgres}"
BACKUP_DIR="${BACKUP_DIR:-/backups}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
BACKUP_ALL_DBS="${BACKUP_ALL_DBS:-false}"

# Generate timestamp
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
DATE_ONLY=$(date +%Y-%m-%d)

# Backup files
if [ "${BACKUP_ALL_DBS}" = "true" ]; then
    FULL_BACKUP="${BACKUP_DIR}/postgres_all_${TIMESTAMP}.sql.gz"
    SCHEMA_BACKUP="${BACKUP_DIR}/postgres_all_schema_${DATE_ONLY}.sql"
    LATEST_LINK="${BACKUP_DIR}/postgres_all_latest.sql.gz"
else
    FULL_BACKUP="${BACKUP_DIR}/postgres_${POSTGRES_DB}_${TIMESTAMP}.sql.gz"
    SCHEMA_BACKUP="${BACKUP_DIR}/postgres_${POSTGRES_DB}_schema_${DATE_ONLY}.sql"
    LATEST_LINK="${BACKUP_DIR}/postgres_${POSTGRES_DB}_latest.sql.gz"
fi

echo "=========================================="
echo "PostgreSQL Database Export"
echo "=========================================="
echo "Date: $(date)"
echo "Host: ${POSTGRES_HOST}:${POSTGRES_PORT}"
echo "User: ${POSTGRES_USER}"
if [ "${BACKUP_ALL_DBS}" = "true" ]; then
    echo "Mode: All Databases"
else
    echo "Database: ${POSTGRES_DB}"
fi
echo "Backup Directory: ${BACKUP_DIR}"
echo "Retention: ${RETENTION_DAYS} days"
echo "=========================================="

# Export PGPASSWORD for authentication
export PGPASSWORD="${POSTGRES_PASSWORD}"

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
    if pg_isready -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" >/dev/null 2>&1; then
        echo "✓ PostgreSQL is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "✗ Error: PostgreSQL is not responding after 30 seconds"
        exit 1
    fi
    sleep 1
done

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Export full database (compressed)
echo ""
if [ "${BACKUP_ALL_DBS}" = "true" ]; then
    echo "Exporting all databases..."
    if pg_dumpall -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" 2>/dev/null | gzip > "${FULL_BACKUP}"; then
        BACKUP_SIZE=$(du -h "${FULL_BACKUP}" | cut -f1)
        echo "✓ Full backup created: ${FULL_BACKUP} (${BACKUP_SIZE})"

        # Create/update 'latest' symlink
        ln -sf "$(basename "${FULL_BACKUP}")" "${LATEST_LINK}"
        echo "✓ Latest backup link updated"
    else
        echo "✗ Error: Full backup failed"
        exit 1
    fi

    # Export schema only for all databases
    echo ""
    echo "Exporting all database schemas..."
    if pg_dumpall -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" --schema-only > "${SCHEMA_BACKUP}" 2>/dev/null; then
        SCHEMA_SIZE=$(du -h "${SCHEMA_BACKUP}" | cut -f1)
        echo "✓ Schema backup created: ${SCHEMA_BACKUP} (${SCHEMA_SIZE})"
    else
        echo "✗ Error: Schema backup failed"
        exit 1
    fi
else
    echo "Exporting database ${POSTGRES_DB}..."
    if pg_dump -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" \
        -d "${POSTGRES_DB}" \
        --clean \
        --if-exists \
        --create 2>/dev/null | gzip > "${FULL_BACKUP}"; then

        BACKUP_SIZE=$(du -h "${FULL_BACKUP}" | cut -f1)
        echo "✓ Full backup created: ${FULL_BACKUP} (${BACKUP_SIZE})"

        # Create/update 'latest' symlink
        ln -sf "$(basename "${FULL_BACKUP}")" "${LATEST_LINK}"
        echo "✓ Latest backup link updated"
    else
        echo "✗ Error: Full backup failed"
        exit 1
    fi

    # Export schema only
    echo ""
    echo "Exporting database schema..."
    if pg_dump -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" \
        -d "${POSTGRES_DB}" \
        --schema-only \
        --clean \
        --if-exists \
        --create > "${SCHEMA_BACKUP}" 2>/dev/null; then

        SCHEMA_SIZE=$(du -h "${SCHEMA_BACKUP}" | cut -f1)
        echo "✓ Schema backup created: ${SCHEMA_BACKUP} (${SCHEMA_SIZE})"
    else
        echo "✗ Error: Schema backup failed"
        exit 1
    fi
fi

# Cleanup old backups (keep only last N days)
echo ""
echo "Cleaning up old backups (keeping ${RETENTION_DAYS} days)..."
DELETED_COUNT=0

# Find and delete old full backups
if [ "${BACKUP_ALL_DBS}" = "true" ]; then
    find "${BACKUP_DIR}" -name "postgres_all_*.sql.gz" -type f -mtime +${RETENTION_DAYS} -print0 | while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            echo "  Deleting: $(basename "$file")"
            rm -f "$file"
            DELETED_COUNT=$((DELETED_COUNT + 1))
        fi
    done

    # Find and delete old schema backups
    find "${BACKUP_DIR}" -name "postgres_all_schema_*.sql" -type f -mtime +${RETENTION_DAYS} -print0 | while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            echo "  Deleting: $(basename "$file")"
            rm -f "$file"
        fi
    done
else
    find "${BACKUP_DIR}" -name "postgres_${POSTGRES_DB}_*.sql.gz" -type f -mtime +${RETENTION_DAYS} -print0 | while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            echo "  Deleting: $(basename "$file")"
            rm -f "$file"
            DELETED_COUNT=$((DELETED_COUNT + 1))
        fi
    done

    # Find and delete old schema backups
    find "${BACKUP_DIR}" -name "postgres_${POSTGRES_DB}_schema_*.sql" -type f -mtime +${RETENTION_DAYS} -print0 | while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            echo "  Deleting: $(basename "$file")"
            rm -f "$file"
        fi
    done
fi

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
ls -lh "${BACKUP_DIR}"/postgres_*.sql.gz 2>/dev/null | tail -5 || echo "  No backups found"
echo ""
TOTAL_SIZE=$(du -sh "${BACKUP_DIR}" 2>/dev/null | cut -f1 || echo "0")
BACKUP_COUNT=$(find "${BACKUP_DIR}" -name "postgres_*.sql.gz" -type f | wc -l | tr -d ' ')
echo "Total backups: ${BACKUP_COUNT}"
echo "Total size: ${TOTAL_SIZE}"
echo "=========================================="
echo "✓ Backup completed successfully"
echo "=========================================="
