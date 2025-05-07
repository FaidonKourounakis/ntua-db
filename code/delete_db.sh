#!/bin/bash

set -e

# Default Postgres user
PG_USER="postgres"
CUSTOM_USER="admin"
DB_NAME="ntua_db"

# Start Postgres if not already running
sudo systemctl start postgresql-17.service

# Drop the database if it exists
DB_EXIST=$(sudo -u $PG_USER psql -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'")
if [ "$DB_EXIST" = "1" ]; then
    echo "Database $DB_NAME exists. Dropping it..."
    sudo -u $PG_USER psql -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE datname='$DB_NAME' AND pid <> pg_backend_pid();"
    sudo -u $PG_USER psql -c "DROP DATABASE $DB_NAME;"
fi

echo "Cleanup complete."
