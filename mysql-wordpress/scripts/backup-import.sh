#!/bin/bash
# MySQL Database Import Script
# This script imports a WordPress database backup

set -e

# Configuration from environment variables or defaults
MYSQL_HOST="${MYSQL_HOST:-db}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-secret}"
MYSQL_DATABASE="${MYSQL_DATABASE:-wordpress}"
BACKUP_DIR="${BACKUP_DIR:-/dumps}"
BACKUP_FILE="${BACKUP_FILE:-}"

echo "=========================================="
echo "MySQL Database Import"
echo "=========================================="
echo "Date: $(date)"
echo "Host: ${MYSQL_HOST}:${MYSQL_PORT}"
echo "Database: ${MYSQL_DATABASE}"
echo "Backup Directory: ${BACKUP_DIR}"
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

# Determine which backup file to use
if [ -z "${BACKUP_FILE}" ]; then
    # No specific file provided, use latest
    if [ -f "${BACKUP_DIR}/wordpress_latest.sql.gz" ]; then
        BACKUP_FILE="${BACKUP_DIR}/wordpress_latest.sql.gz"
        echo "Using latest backup: ${BACKUP_FILE}"
    else
        # Find the most recent backup
        BACKUP_FILE=$(find "${BACKUP_DIR}" -name "wordpress_*.sql.gz" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
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
        ls -lh "${BACKUP_DIR}"/wordpress_*.sql.gz 2>/dev/null || echo "  No backups found"
        exit 1
    fi
    echo "Using specified backup: ${BACKUP_FILE}"
fi

# Show backup info
BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
BACKUP_DATE=$(date -r "${BACKUP_FILE}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "${BACKUP_FILE}")
echo ""
echo "Backup Information:"
echo "  File: $(basename "${BACKUP_FILE}")"
echo "  Size: ${BACKUP_SIZE}"
echo "  Date: ${BACKUP_DATE}"
echo ""

# Confirmation warning
echo "⚠️  WARNING: This will replace the current database!"
echo "   Database: ${MYSQL_DATABASE}"
echo "   Host: ${MYSQL_HOST}"
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
SAFETY_BACKUP="${BACKUP_DIR}/wordpress_before_import_$(date +%Y%m%d_%H%M%S).sql.gz"
echo ""
echo "Creating safety backup before import..."
if mysqldump -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -uroot -p"${MYSQL_ROOT_PASSWORD}" \
    --single-transaction \
    --databases "${MYSQL_DATABASE}" 2>/dev/null | gzip > "${SAFETY_BACKUP}"; then
    echo "✓ Safety backup created: $(basename "${SAFETY_BACKUP}")"
else
    echo "⚠️  Warning: Could not create safety backup, but continuing..."
fi

# Import the backup
echo ""
echo "Importing database..."
if [ "${BACKUP_FILE}" == *.gz ]; then
    # Compressed backup
    if gunzip < "${BACKUP_FILE}" | mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -uroot -p"${MYSQL_ROOT_PASSWORD}" 2>/dev/null; then
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
else
    # Uncompressed backup
    if mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -uroot -p"${MYSQL_ROOT_PASSWORD}" < "${BACKUP_FILE}" 2>/dev/null; then
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

# Verify import
echo ""
echo "Verifying import..."
TABLE_COUNT=$(mysql -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -uroot -p"${MYSQL_ROOT_PASSWORD}" \
    -D"${MYSQL_DATABASE}" -se "SHOW TABLES;" 2>/dev/null | wc -l | tr -d ' ')

if [ "${TABLE_COUNT}" -gt 0 ]; then
    echo "✓ Database verified: ${TABLE_COUNT} tables found"
else
    echo "⚠️  Warning: No tables found in database"
fi

# Summary
echo ""
echo "=========================================="
echo "Import Summary"
echo "=========================================="
echo "Database: ${MYSQL_DATABASE}"
echo "Tables: ${TABLE_COUNT}"
echo "Source: $(basename "${BACKUP_FILE}")"
echo "Status: Success"
echo "=========================================="
echo "✓ Import completed successfully"
echo "=========================================="
