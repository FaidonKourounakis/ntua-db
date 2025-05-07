#!/bin/bash

# Database credentials
DB_NAME="ntua_db"
DB_USER="admin"
DB_PASS="admin"
DB_HOST="localhost"

# Export password to avoid password prompt
export PGPASSWORD=$DB_PASS

# Loop through queries from 01 to 15
for i in $(seq -w 1 15); do
    SQL_FILE="../sql/Q${i}.sql"
    OUTPUT_FILE="../sql/Q${i}_out.txt"

    if [ -f "$SQL_FILE" ]; then
        echo "Executing query from $SQL_FILE..."
        psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "$SQL_FILE" -o "$OUTPUT_FILE"
        echo "Output saved to $OUTPUT_FILE"
    else
        echo "File $SQL_FILE not found, skipping..."
    fi
done

# Unset password for security
unset PGPASSWORD

