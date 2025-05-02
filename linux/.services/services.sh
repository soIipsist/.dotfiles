SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_scripts_directory="$SCRIPT_DIR/services"
dest_scripts_directory="/etc//systemd/system/"

services=($(ls $SCRIPT_DIR))

for bin_script in "${bin_scripts[@]}"; do
    sudo cp -f "$source_scripts_directory/$bin_script" "$dest_scripts_directory"
    sudo chmod +x "$dest_scripts_directory/$(basename "$bin_script")"
    echo "Copied $bin_script to $dest_scripts_directory."
done
