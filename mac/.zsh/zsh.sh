destination_directory="$dotfiles_directory"

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

source_scripts_directory="$PWD/.zsh/scripts"
dest_scripts_directory="/usr/local/bin"

# copy scripts to /bin
bin_scripts=($(ls $source_scripts_directory))

for bin_script in "$bin_scripts"; do
    if [ -f "$bin_script" ]; then
        sudo cp -f "$bin_script" "$scripts_directory"
        sudo chmod +x "$dest_scripts_directory/$(basename "$bin_script")"
    fi
done
