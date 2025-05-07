#!/bin/bash

# Config
INPUT_FILE="../sql/load.sql"
OUTPUT_DIR="../sql"
MIN_SIZE_MB=30
MAX_SIZE_MB=40

# Prepare
mkdir -p "$OUTPUT_DIR"
chunk_num=1
current_file="$OUTPUT_DIR/load_part_$chunk_num.sql"
> "$current_file"
current_size=0

# Function to get file size in MB
get_file_size_mb() {
    local file="$1"
    echo $(( $(stat -c%s "$file") / 1024 / 1024 ))
}

# Read and write
statement=""
while IFS= read -r line || [ -n "$line" ]; do
    statement+="$line"$'\n'
    
    # Check if line ends with semicolon (trailing spaces allowed)
    if [[ "$line" == *\; ]]; then
        echo -n "$statement" >> "$current_file"
        current_size=$(get_file_size_mb "$current_file")
        
        if (( current_size >= MAX_SIZE_MB )); then
            ((chunk_num++))
            current_file="$OUTPUT_DIR/load_part_$chunk_num.sql"
            > "$current_file"
        fi
        
        statement=""
    fi
done < "$INPUT_FILE"

# Write any remaining statement (in case the file doesn't end with ;)
if [[ -n "$statement" ]]; then
    echo -n "$statement" >> "$current_file"
fi

echo "Splitting complete. Chunks saved in $OUTPUT_DIR as load_part_X.sql."
