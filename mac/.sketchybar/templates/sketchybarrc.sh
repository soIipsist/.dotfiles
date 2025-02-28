# generate sketchybarrc

if [ -z $sketchybar_template ]; then
    sketchybar_template="main"
fi

templates_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sketchybar_template_path="$templates_directory/$sketchybar_template"

if [ -f "$sketchybar_template_path" ]; then # sketchybar only
    cp -f "$templates_directory/$sketchybar_template" "$dotfiles_directory/.config/sketchybar/sketchybarrc"
    echo "Successfully copied "
    sketchybar --reload
else
    # copy bottom and top parts
    cp -f "$templates_directory/bottom_$sketchybar_template" "$dotfiles_directory/.config/bottombar/sketchybarrc"
    cp -f "$templates_directory/top_$sketchybar_template" "$dotfiles_directory/.config/sketchybar/sketchybarrc"
    sketchybar --reload
    bottombar --reload
fi
