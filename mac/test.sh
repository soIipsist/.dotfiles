source "../dotfiles.sh"

base_dir="$HOME/Desktop"
destination_directory="$HOME/Desktop/test"

dotfiles=$(get_dotfiles $base_dir)

move_dotfiles "${dotfiles[@]}" "${destination_directory}"