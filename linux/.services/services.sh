#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_services_directory="$SCRIPT_DIR/services"
dest_services_directory="/etc/systemd/system/"
dest_config_directory="/etc/default/"

copy() {
    file="$1"
    dest_directory="$2"
    filename="$3"

    if [ -z "$filename" ]; then
        filename="$(basename "$file")"
    fi

    sudo cp -f "$file" "$dest_directory/$filename"

    # chmod files
    sudo chmod 644 "$dest_directory/$filename"
    echo "Copied $filename to $dest_directory."
}

for file in "$source_services_directory"/*.service; do
    copy "$file" "$dest_services_directory"

    service_name="$(basename "$file")"
    service_base="${service_name%.service}"

    log_dir="/tmp/logs"
    log_file="$log_dir/${service_base}.log"
    err_file="$log_dir/${service_base}.err"

    # Create log directory if it doesn't exist
    mkdir -p "$log_dir"

    # Recreate log files with correct ownership and permissions
    sudo touch "$log_file" "$err_file"
    sudo chown $(whoami):$(whoami) "$log_file" "$err_file"
    sudo chmod 644 "$log_file" "$err_file"

    echo "Created log files for $service_base in $log_dir."
done

for file in "$source_services_directory"/*.conf; do

    filename="$(basename "$file")"
    temp_file="$(mktemp)"

    envsubst <"$file" >"$temp_file"
    copy "$temp_file" "$dest_config_directory" "$filename"
    rm "$temp_file"

    echo "Generated and copied $filename to $dest_config_directory."
done

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload
