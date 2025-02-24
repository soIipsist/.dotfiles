if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi
destination_directory="$dotfiles_directory/.config/sketchybar"
plugins_directory="$destination_directory/plugins"
source_plugins_directory="$PWD/.sketchybar/plugins"
source_templates_directory="$PWD/.sketchybar/templates"

# copy sketchybar template, if defined
if [ -n "$sketchybar_template" ]; then
    cp -f "$source_templates_directory/$sketchybar_template" "$PWD/.sketchybar/sketchybarrc" #replace sketchybarrc with template
fi

# copy plugins
files=($(ls $source_plugins_directory))

for file in "${files[@]}"; do
    cp -f "$source_plugins_directory/$file" "$plugins_directory"
    chmod +x "$plugins_directory/$file"
done

source "$dotfiles_directory/.config/sketchybar/plugins/reload.sh"
