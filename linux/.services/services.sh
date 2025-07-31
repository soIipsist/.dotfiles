#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_services_directory="$SCRIPT_DIR/services"
dest_services_directory="/etc/systemd/system/"
dest_config_directory="/etc/default/"

group="shared_group"
sudo addgroup $group

copy() {
    file="$1"
    dest_directory="$2"
    filename="$3"

    if [ -z "$filename" ]; then
        filename="$(basename "$file")"
    fi

    sudo cp -f "$file" "$dest_directory/$filename"

    # chmod files
    sudo chmod 664 "$dest_directory/$filename"
    sudo chown $(whoami):$group "$dest_directory/$filename"
    echo "Copied $filename to $dest_directory."
}

for file in "$source_services_directory"/*.service; do
    copy "$file" "$dest_services_directory"

    service_name="$(basename "$file")"
    service_base="${service_name%.service}"

    log_dir="srv/shared/tmp"
    log_file="$log_dir/${service_base}.log"
    err_file="$log_dir/${service_base}.err"

    # Create log directory if it doesn't exist
    mkdir -p "$log_dir"
    sudo chown root:$group "$log_dir"
    sudo chmod 2775 "$log_dir"

    # Recreate log files with correct ownership and permissions
    sudo touch "$log_file" "$err_file"
    sudo chown $(whoami):$group "$log_file" "$err_file"
    sudo chmod 664 "$log_file" "$err_file"

    echo "Created log files for $service_base in $log_dir."
done

for file in "$source_services_directory"/*.conf; do

    filename="$(basename "$file")"
    temp_file="$(mktemp)"
    envsubst <"$file" >"$temp_file"

    state_file=$(grep -oP 'STATE_FILE="\K[^"]+' "$temp_file")

    if [ -n "$state_file" ]; then
        sudo mkdir -p "$(dirname "$state_file")"
        sudo touch "$state_file"

        echo "Created state file $state_file"
    fi
    sudo chown "$(whoami):$group" "$state_file"
    sudo chmod 664 "$state_file"

    copy "$temp_file" "$dest_config_directory" "$filename"
    rm "$temp_file"

    echo "Generated and copied $filename to $dest_config_directory."
done

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload
