#!/bin/bash

# Database credentials
DB_NAME="ntua_db"
DB_USER="admin"
DB_PASS="admin"
DB_HOST="localhost"

# Export password to avoid password prompt
export PGPASSWORD=$DB_PASS

SQL_FILE="../sql/${1}.sql"
OUTPUT_FILE="../sql/${1}_out.txt"

if [ -f "$SQL_FILE" ]; then
    echo "Executing query from $SQL_FILE..."
    psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "$SQL_FILE" -o "$OUTPUT_FILE"
    echo "Output saved to $OUTPUT_FILE"
else
    echo "File $SQL_FILE not found, skipping..."
fi

# Unset password for security
unset PGPASSWORD

