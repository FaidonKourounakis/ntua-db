#!/bin/bash

set -e

# Default Postgres user
PG_USER="postgres"
NEW_USER="admin"
NEW_PASS="admin"
DB_NAME="ntua_db"
DB_HOST="localhost"

# Start postgres if not started
sudo systemctl start postgresql-17.service

# Create the new user if it doesn't exist
sudo -u $PG_USER psql <<EOF
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$NEW_USER') THEN
        CREATE USER $NEW_USER WITH PASSWORD '$NEW_PASS';
    END IF;
END\$\$;
EOF

# Drop database if exists and recreate
DB_EXIST=$(sudo -u $PG_USER psql -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'")
if [ "$DB_EXIST" = "1" ]; then
    echo "Database $DB_NAME exists. Dropping it..."
    # Terminate active connections
    sudo -u $PG_USER psql -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE datname='$DB_NAME' AND pid <> pg_backend_pid();"
    # Drop database
    sudo -u $PG_USER psql -c "DROP DATABASE IF EXISTS $DB_NAME;"
fi

# Create fresh database
echo "Creating database $DB_NAME..."
sudo -u $PG_USER psql -c "CREATE DATABASE $DB_NAME;"
sudo -u $PG_USER psql -c "ALTER DATABASE $DB_NAME OWNER TO $NEW_USER;"

# Grant privileges
sudo -u $PG_USER psql <<EOF
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $NEW_USER;
GRANT ALL ON SCHEMA public TO $NEW_USER;
EOF

# Export password to avoid prompt
export PGPASSWORD=$NEW_PASS

# Run install.sql and load.sql as admin
if [ -f "../sql/install.sql" ]; then
    psql -h $DB_HOST -U $NEW_USER -d $DB_NAME -f "../sql/install.sql"
fi

if [ -f "../sql/load.sql" ]; then
    psql -h $DB_HOST -U $NEW_USER -d $DB_NAME -f "../sql/load.sql"
fi

# Unset password for security
unset PGPASSWORD