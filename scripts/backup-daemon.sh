#!/bin/sh

# Default backup interval: 6 hours
BACKUP_INTERVAL="${BACKUP_INTERVAL:-21600}"

# Ensure we have required env vars
if [ -z "$S3_BUCKET" ]; then
    echo "ERROR: S3_BUCKET not set. Backup disabled."
    sleep infinity
fi

if [ -z "$RESTIC_PASSWORD" ]; then
    echo "ERROR: RESTIC_PASSWORD not set. Backup disabled."
    sleep infinity
fi

# Configure Restic Repository
export RESTIC_REPOSITORY="s3:${S3_ENDPOINT}/${S3_BUCKET}/restic"
export AWS_ACCESS_KEY_ID="${S3_ACCESS_KEY}"
export AWS_SECRET_ACCESS_KEY="${S3_SECRET_KEY}"

echo "Initializing Restic Repository at $RESTIC_REPOSITORY..."
restic init || echo "Repository already initialized or accessible."

# Check for --once flag
ONCE=0
for arg in "$@"; do
    if [ "$arg" = "--once" ]; then
        ONCE=1
    fi
done

# Main Loop
while true; do
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    echo "Starting backup job at $TIMESTAMP..."

    # 1. CockroachDB Dump (Hot Backup)
    # We prefer pg_dump for Community Edition as 'cockroach dump' is deprecated/removed
    
    echo "Dumping Database..."
    mkdir -p /tmp/db_dump
    
    if command -v pg_dump >/dev/null 2>&1; then
        # Use pg_dump if available (Standard for Community Edition)
        echo "Using pg_dump..."
        PGPASSWORD=${CR_USER_PASSWORD:-root} pg_dump \
            -h cockroach -p 26257 -U root -d huly \
            -f /tmp/db_dump/huly.sql || echo "pg_dump failed"
            
    elif command -v cockroach >/dev/null 2>&1; then
        # Fallback to cockroach sql (Enterprise/Legacy)
        # Check connection first
        cockroach sql --url "postgres://root@cockroach:26257/defaultdb?sslmode=disable" \
            --format=csv \
            -e "SELECT 1" >/dev/null 2>&1 || echo "CockroachDB check failed."

        echo "Attempting cockroach dump (legacy)..."
        cockroach dump huly \
            --url "postgres://root@cockroach:26257/huly?sslmode=disable" \
            > /tmp/db_dump/huly.sql 2>/tmp/db_dump/dump.log || cat /tmp/db_dump/dump.log
    else
        echo "ERROR: No database dump tool found (pg_dump or cockroach)."
    fi

    # 2. Restic Backup
    echo "Running Restic Backup..."
    # Backup files + DB dump
    restic backup /backup/files /tmp/db_dump \
        --tag "scheduled" \
        --host "huly-production"

    # 3. Prune Old Snapshots
    echo "Pruning old snapshots..."
    restic forget \
        --keep-last 4 \
        --keep-daily 7 \
        --keep-weekly 4 \
        --keep-monthly 6 \
        --prune

    # Cleanup
    rm -rf /tmp/db_dump

    if [ "$ONCE" -eq 1 ]; then
        echo "Single run completed. Exiting."
        exit 0
    fi

    echo "Backup completed. Sleeping for $BACKUP_INTERVAL seconds..."
    sleep $BACKUP_INTERVAL
done
