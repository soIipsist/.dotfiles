destination_directory="$dotfiles_directory"

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_scripts_directory="$SCRIPT_DIR/scripts"
dest_scripts_directory="/usr/local/bin"

# copy scripts to /bin
bin_scripts=($(ls $source_scripts_directory))

for bin_script in "${bin_scripts[@]}"; do
    sudo cp -f "$source_scripts_directory/$bin_script" "$dest_scripts_directory"
    sudo chmod +x "$dest_scripts_directory/$(basename "$bin_script")"
    echo "Copied $bin_script to $dest_scripts_directory."
done
