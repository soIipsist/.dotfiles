#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINERS_FOLDER="$HOME/.containers"
COMPOSE_DIR="$SCRIPT_DIR/compose"

# Ensure the containers base directory exists
mkdir -p "$CONTAINERS_FOLDER"

compose_files=("$COMPOSE_DIR"/*.{yml,yaml})

for file in "${compose_files[@]}"; do
    filename=$(basename "$file")
    service_name="${filename%.*}" 

    dest_dir="$CONTAINERS_FOLDER/$service_name/"
    final_path="$dest_dir/compose.yaml"

    mkdir -p "$dest_dir"

    echo "Copying '$filename' into directory structure..."
    cp -f "$file" "$final_path"
    echo "Successfully copied to: $final_path"
done

