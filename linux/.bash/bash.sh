destination_directory="$dotfiles_directory"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_scripts_directory="$SCRIPT_DIR/scripts"
dest_scripts_directory="/usr/local/bin"

# copy scripts to /bin
bin_scripts=($(ls $source_scripts_directory))

for bin_script in "${bin_scripts[@]}"; do
    dest_file="$dest_scripts_directory/$(basename "$bin_script")"

    sudo cp -f "$source_scripts_directory/$bin_script" "$dest_file"
    sudo chmod 755 "$dest_file"         # Executable by everyone, writable by owner
    sudo chown $USER:$USER "$dest_file" # Set ownership to current user

    echo "Copied $bin_script to $dest_scripts_directory and updated permissions."
done
