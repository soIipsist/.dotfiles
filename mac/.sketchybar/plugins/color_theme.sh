OPTION="$1"
DOTFILES_DIRECTORY="$2"

color_scheme="$OPTION"

if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory=$HOME
fi

set_colors_path="$dotfiles_directory/.config/colors/set_colors.sh"
source "$set_colors_path"

sketchybar -m --set theme.logo label=""
sketchybar -m --set theme.logo popup.drawing=off
