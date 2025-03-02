if [ -z $sketchybar_type ]; then
    sketchybar_type="main"
fi

templates_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sketchybar_type_path="$templates_directory/$sketchybar_type"

# generate sketchybarrc

if [ -f "$sketchybar_type_path" ]; then # sketchybar only
    cp -f "$templates_directory/$sketchybar_type" "$dotfiles_directory/.config/sketchybar/sketchybarrc"
    sketchybar --reload
else
    # copy bottom and top parts
    cp -f "$templates_directory/bottom_$sketchybar_type" "$dotfiles_directory/.config/bottombar/sketchybarrc"
    cp -f "$templates_directory/top_$sketchybar_type" "$dotfiles_directory/.config/sketchybar/sketchybarrc"
    sketchybar --reload
    bottombar --reload
fi
