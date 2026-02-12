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
    # We use pg_dump (psql) or cockroach dump via the built-in binary in the image
    # Note: The sidecar image should have postgresql-client or cockroach binary
    
    echo "Dumping Database..."
    mkdir -p /tmp/db_dump
    
    # Using pg_dump if available, else cockroach sql
    # Connection string: postgres://root@cockroach:26257/defaultdb?sslmode=disable
    # We use root for dump to ensure we get everything permissions-wise
    
    if command -v cockroach >/dev/null 2>&1; then
        cockroach sql --url "postgres://root@cockroach:26257/defaultdb?sslmode=disable" \
            --format=csv \
            -e "SELECT 1" >/dev/null 2>&1 || echo "CockroachDB check failed."

        # Note: BACKUP statement requires enterprise/S3. We use dump for community.
        echo "Exporting SQL dump..."
        cockroach dump huly \
            --url "postgres://root@cockroach:26257/huly?sslmode=disable" \
            > /tmp/db_dump/huly.sql 2>/tmp/db_dump/dump.log || cat /tmp/db_dump/dump.log
            
    elif command -v pg_dump >/dev/null 2>&1; then
        PGPASSWORD=${CR_USER_PASSWORD} pg_dump \
            -h cockroach -p 26257 -U root -d huly \
            -f /tmp/db_dump/huly.sql
    else
        echo "ERROR: No database dump tool found (cockroach or pg_dump)."
        # We continue to backup files at least
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
