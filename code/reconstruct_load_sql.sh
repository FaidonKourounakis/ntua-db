#!/bin/bash

# Config
INPUT_DIR="../sql"
OUTPUT_FILE="../sql/load.sql"

# Prepare output file
> "$OUTPUT_FILE"

# Concatenate all parts in order
for part in $(ls "$INPUT_DIR"/load_part_*.sql | sort -V); do
    echo "-- Appending $part" >> "$OUTPUT_FILE"
    cat "$part" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

echo "Reconstruction complete. Combined file saved as $OUTPUT_FILE."
