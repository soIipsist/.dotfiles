destination_directory="$dotfiles_directory"

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

scripts_directory="/usr/local/bin"
source_scripts_directory="$PWD/.zsh/scripts"

# copy scripts to /bin
scripts=($(ls $source_scripts_directory))

for script in "$source_scripts_directory"/*; do
    if [ -f "$script" ]; then
        sudo cp -f "$script" "$scripts_directory"
        sudo chmod +x "$scripts_directory/$(basename "$script")"
    fi
done

# copy colors
cp -f "$PWD/.zsh/colors.sh" $destination_directory
chmod +x "$destination_directory/colors.sh"
echo $destination_directory
