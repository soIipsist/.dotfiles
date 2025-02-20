if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

destination_directory="$dotfiles_directory/.config/iterm2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

scripts=("generate_plist.sh" "set_theme.sh")

for script in "${scripts[@]}"; do
    cp -f "$SCRIPT_DIR/scripts/$script" "$destination_directory/$script"
    chmod +x "$destination_directory/$script"
done

source "$destination_directory/generate_plist.sh" "$SCRIPT_DIR"
# source "$destination_directory/set_theme.sh" ""
