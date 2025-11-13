#!/bin/bash
# PostgreSQL Database Import Script
# This script imports a PostgreSQL database backup

set -e

# Configuration from environment variables or defaults
POSTGRES_HOST="${POSTGRES_HOST:-postgres}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-postgres}"
BACKUP_DIR="${BACKUP_DIR:-/backups}"
BACKUP_FILE="${BACKUP_FILE:-}"
RESTORE_ALL_DBS="${RESTORE_ALL_DBS:-false}"

echo "=========================================="
echo "PostgreSQL Database Import"
echo "=========================================="
echo "Date: $(date)"
echo "Host: ${POSTGRES_HOST}:${POSTGRES_PORT}"
echo "User: ${POSTGRES_USER}"
if [ "${RESTORE_ALL_DBS}" = "true" ]; then
    echo "Mode: All Databases"
else
    echo "Database: ${POSTGRES_DB}"
fi
echo "Backup Directory: ${BACKUP_DIR}"
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

# Determine which backup file to use
if [ -z "${BACKUP_FILE}" ]; then
    # No specific file provided, use latest
    if [ "${RESTORE_ALL_DBS}" = "true" ]; then
        PATTERN="postgres_all_*.sql.gz"
        LATEST_LINK="${BACKUP_DIR}/postgres_all_latest.sql.gz"
    else
        PATTERN="postgres_${POSTGRES_DB}_*.sql.gz"
        LATEST_LINK="${BACKUP_DIR}/postgres_${POSTGRES_DB}_latest.sql.gz"
    fi

    if [ -f "${LATEST_LINK}" ]; then
        BACKUP_FILE="${LATEST_LINK}"
        echo "Using latest backup: ${BACKUP_FILE}"
    else
        # Find the most recent backup
        BACKUP_FILE=$(find "${BACKUP_DIR}" -name "${PATTERN}" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
        if [ -z "${BACKUP_FILE}" ]; then
            echo "✗ Error: No backup files found in ${BACKUP_DIR}"
            echo ""
            echo "Available files:"
            ls -lh "${BACKUP_DIR}" || echo "  Directory is empty"
            exit 1
        fi
        echo "Using most recent backup: ${BACKUP_FILE}"
    fi
else
    # Specific file provided
    if [ ! -f "${BACKUP_FILE}" ]; then
        echo "✗ Error: Backup file not found: ${BACKUP_FILE}"
        echo ""
        echo "Available backups:"
        ls -lh "${BACKUP_DIR}"/postgres_*.sql.gz 2>/dev/null || echo "  No backups found"
        exit 1
    fi
    echo "Using specified backup: ${BACKUP_FILE}"
fi

# Show backup info
BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
if [ "$(uname)" = "Darwin" ]; then
    BACKUP_DATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "${BACKUP_FILE}")
else
    BACKUP_DATE=$(date -r "${BACKUP_FILE}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
fi

echo ""
echo "Backup Information:"
echo "  File: $(basename "${BACKUP_FILE}")"
echo "  Size: ${BACKUP_SIZE}"
echo "  Date: ${BACKUP_DATE}"
echo ""

# Confirmation warning
if [ "${RESTORE_ALL_DBS}" = "true" ]; then
    echo "⚠️  WARNING: This will replace ALL databases!"
else
    echo "⚠️  WARNING: This will replace the current database!"
    echo "   Database: ${POSTGRES_DB}"
fi
echo "   Host: ${POSTGRES_HOST}"
echo ""

# Check if running interactively
if [ -t 0 ]; then
    read -p "Continue with import? (yes/no): " -r CONFIRM
    if [ "${CONFIRM}" != "yes" ]; then
        echo "Import cancelled by user"
        exit 0
    fi
else
    echo "Running in non-interactive mode, proceeding with import..."
fi

# Create a quick backup before importing (safety measure)
if [ "${RESTORE_ALL_DBS}" = "true" ]; then
    SAFETY_BACKUP="${BACKUP_DIR}/postgres_all_before_import_$(date +%Y%m%d_%H%M%S).sql.gz"
    echo ""
    echo "Creating safety backup of all databases before import..."
    if pg_dumpall -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" 2>/dev/null | gzip > "${SAFETY_BACKUP}"; then
        echo "✓ Safety backup created: $(basename "${SAFETY_BACKUP}")"
    else
        echo "⚠️  Warning: Could not create safety backup, but continuing..."
    fi
else
    SAFETY_BACKUP="${BACKUP_DIR}/postgres_${POSTGRES_DB}_before_import_$(date +%Y%m%d_%H%M%S).sql.gz"
    echo ""
    echo "Creating safety backup before import..."
    if pg_dump -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" \
        -d "${POSTGRES_DB}" 2>/dev/null | gzip > "${SAFETY_BACKUP}"; then
        echo "✓ Safety backup created: $(basename "${SAFETY_BACKUP}")"
    else
        echo "⚠️  Warning: Could not create safety backup, but continuing..."
    fi
fi

# Import the backup
echo ""
echo "Importing database..."
if [ "${BACKUP_FILE}" == *.gz ]; then
    # Compressed backup
    if [ "${RESTORE_ALL_DBS}" = "true" ]; then
        if gunzip < "${BACKUP_FILE}" | psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" postgres 2>/dev/null; then
            echo "✓ All databases imported successfully"
        else
            echo "✗ Error: Database import failed"
            if [ -f "${SAFETY_BACKUP}" ]; then
                echo ""
                echo "You can restore the safety backup with:"
                echo "  BACKUP_FILE=${SAFETY_BACKUP} RESTORE_ALL_DBS=true docker-compose run --rm dbimport"
            fi
            exit 1
        fi
    else
        if gunzip < "${BACKUP_FILE}" | psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d postgres 2>/dev/null; then
            echo "✓ Database imported successfully"
        else
            echo "✗ Error: Database import failed"
            if [ -f "${SAFETY_BACKUP}" ]; then
                echo ""
                echo "You can restore the safety backup with:"
                echo "  BACKUP_FILE=${SAFETY_BACKUP} docker-compose run --rm dbimport"
            fi
            exit 1
        fi
    fi
else
    # Uncompressed backup
    if [ "${RESTORE_ALL_DBS}" = "true" ]; then
        if psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" postgres < "${BACKUP_FILE}" 2>/dev/null; then
            echo "✓ All databases imported successfully"
        else
            echo "✗ Error: Database import failed"
            if [ -f "${SAFETY_BACKUP}" ]; then
                echo ""
                echo "You can restore the safety backup with:"
                echo "  BACKUP_FILE=${SAFETY_BACKUP} RESTORE_ALL_DBS=true docker-compose run --rm dbimport"
            fi
            exit 1
        fi
    else
        if psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" -d postgres < "${BACKUP_FILE}" 2>/dev/null; then
            echo "✓ Database imported successfully"
        else
            echo "✗ Error: Database import failed"
            if [ -f "${SAFETY_BACKUP}" ]; then
                echo ""
                echo "You can restore the safety backup with:"
                echo "  BACKUP_FILE=${SAFETY_BACKUP} docker-compose run --rm dbimport"
            fi
            exit 1
        fi
    fi
fi

# Verify import
echo ""
echo "Verifying import..."
if [ "${RESTORE_ALL_DBS}" = "true" ]; then
    DB_COUNT=$(psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" \
        -d postgres -t -c "SELECT count(*) FROM pg_database WHERE datistemplate = false;" 2>/dev/null | tr -d ' ')

    if [ "${DB_COUNT}" -gt 0 ]; then
        echo "✓ Databases verified: ${DB_COUNT} database(s) found"
        echo ""
        echo "Database list:"
        psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" \
            -d postgres -c "\l" 2>/dev/null || true
    else
        echo "⚠️  Warning: No databases found"
    fi
else
    TABLE_COUNT=$(psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}" \
        -d "${POSTGRES_DB}" -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')

    if [ "${TABLE_COUNT}" -gt 0 ]; then
        echo "✓ Database verified: ${TABLE_COUNT} table(s) found"
    else
        echo "⚠️  Warning: No tables found in database"
    fi
fi

# Summary
echo ""
echo "=========================================="
echo "Import Summary"
echo "=========================================="
if [ "${RESTORE_ALL_DBS}" = "true" ]; then
    echo "Mode: All Databases"
    echo "Databases: ${DB_COUNT}"
else
    echo "Database: ${POSTGRES_DB}"
    echo "Tables: ${TABLE_COUNT}"
fi
echo "Source: $(basename "${BACKUP_FILE}")"
echo "Status: Success"
echo "=========================================="
echo "✓ Import completed successfully"
echo "=========================================="
