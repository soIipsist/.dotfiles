source "set_theme.sh"

if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

destination_directory="$dotfiles_directory/.config/themes"
rm "$destination_directory"/*.json # removes all existing .json files
