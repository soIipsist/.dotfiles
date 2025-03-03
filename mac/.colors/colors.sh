if [ -z $dotfiles_directory ]; then
    dotfiles_directory="$HOME"
fi

if [ -z $color_preset ]; then
    color_preset="main"
fi

destination_directory="$dotfiles_directory/.config/colors"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_directory="$SCRIPT_DIR"

mkdir -p "$destination_directory"

cp -f "$source_directory/scripts/set_colors.sh" "$destination_directory"
chmod +x "$destination_directory/set_colors.sh"
source "$dotfiles_directory/.config/colors/set_colors.sh" "$color_preset"
source "$dotfiles_directory/.config/sketchybar/plugins/reload.sh"
