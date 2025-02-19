OPTION="$1"
PLUGIN_DIR="$2"

color_scheme="$OPTION"

if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory=$HOME
fi

set_colors_path="$dotfiles_directory/.config/colors/set_colors.sh"
source "$set_colors_path"

sketchybar -m --set colors.logo label="$color_scheme"
sketchybar -m --set colors.logo popup.drawing=off
