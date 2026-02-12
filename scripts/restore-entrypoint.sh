#!/bin/sh

# Restore script for Restic Sidecar
# Usage: docker compose run --rm backup restore

if [ "$1" != "restore" ]; then
    echo "Usage: docker compose run --rm backup restore"
    exit 1
fi

echo "Starting Restore Process..."

# 1. Initialize Repo
export RESTIC_REPOSITORY="s3:${S3_ENDPOINT}/${S3_BUCKET}/restic"
export AWS_ACCESS_KEY_ID="${S3_ACCESS_KEY}"
export AWS_SECRET_ACCESS_KEY="${S3_SECRET_KEY}"

restic init || echo "Repo accessible."

# 2. Find Latest Snapshot
LATEST_SNAPSHOT=$(restic snapshots --json --latest 1 | jq -r '.[0].short_id')

if [ -z "$LATEST_SNAPSHOT" ] || [ "$LATEST_SNAPSHOT" = "null" ]; then
    echo "ERROR: No snapshots found in repository!"
    exit 1
fi

echo "Restoring from Snapshot ID: $LATEST_SNAPSHOT"

# 3. Restore Files (to mounted volume)
echo "Restoring Files..."
restic restore $LATEST_SNAPSHOT --target / --include /backup/files

# 4. Restore Database
echo "Restoring Database Dump..."
restic restore $LATEST_SNAPSHOT --target /tmp --include /tmp/db_dump/huly.sql

if [ -f /tmp/db_dump/huly.sql ]; then
    echo "Importing SQL Dump into CockroachDB..."
    
    # Wait for DB to be ready
    until cockroach sql --url "postgres://root@cockroach:26257/defaultdb?sslmode=disable" -e "SELECT 1" >/dev/null 2>&1; do
        echo "Waiting for CockroachDB..."
        sleep 2
    done

    # ⚠️ DESTRUCTIVE RESTORE: WIPE AND RELOAD
    echo "⚠️  Dropping existing 'huly' database to ensure clean restore..."
    cockroach sql --url "postgres://root@cockroach:26257/defaultdb?sslmode=disable" -e "DROP DATABASE IF EXISTS huly;"
    
    echo "Creating fresh 'huly' database..."
    cockroach sql --url "postgres://root@cockroach:26257/defaultdb?sslmode=disable" -e "CREATE DATABASE huly;"

    # Import SQL Dump
    echo "Importing data..."
    cat /tmp/db_dump/huly.sql | cockroach sql --url "postgres://root@cockroach:26257/huly?sslmode=disable"
    
    echo "Database Import Complete."
    rm -rf /tmp/db_dump
else
    echo "WARNING: No SQL dump found in snapshot."
fi

echo "Restore Completed Successfully."
