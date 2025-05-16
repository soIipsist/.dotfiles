#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_services_directory="$SCRIPT_DIR/services"
dest_services_directory="/etc/systemd/system/"
dest_config_directory="/etc/default/"

copy() {
    file="$1"
    dest_directory="$2"

    filename="$(basename "$file")"
    sudo cp -f "$file" "$dest_directory/$filename"

    # chmod files
    sudo chmod 666 "$dest_directory/$filename"
    sudo chown $(whoami):$(whoami) "$dest_directory/$filename"

    echo "Copied $filename to $dest_directory."
}

for file in "$source_services_directory"/*.service; do
    [[ -e "$file" ]] && copy "$file" "$dest_services_directory"
done

for file in "$source_services_directory"/*.conf; do
    [[ -e "$file" ]] || continue

    filename="$(basename "$file")"
    temp_file="$(mktemp)"

    envsubst <"$file" >"$temp_file"

    copy "$temp_file" "$dest_config_directory/$filename"
    rm "$temp_file"

    echo "Generated and copied $filename to $dest_config_directory."
done
