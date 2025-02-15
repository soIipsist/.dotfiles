if [ -z $dotfiles_directory ]; then
    dotfiles_directory=$HOME
fi

destination_directory="$dotfiles_directory/.config/colors"
source_directory="$PWD/.colors"

mkdir -p $destination_directory
cp -f "$source_directory/set_colors.sh" "$destination_directory"
chmod +x "$destination_directory/set_colors.sh"
source "$destination_directory/set_colors.sh"

echo $destination_directory
