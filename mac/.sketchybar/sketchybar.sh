if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

# copy plugins to /sketchybar/plugins
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source_plugins_directory="$SCRIPT_DIR/plugins"
plugins_directory="$dotfiles_directory/.config/sketchybar/plugins"

# create sketchybar dir
mkdir -p "$dotfiles_directory/.config/sketchybar"

rm "$plugins_directory"/*.sh

for file in "$source_plugins_directory"/*; do
    original_name=$(basename $file)
    dest_plugin="$plugins_directory/$original_name"
    cp -f "$file" "$dest_plugin"
    chmod +x "$dest_plugin"
done

# copy set_template script
source "$plugins_directory/set_template.sh" "$SKETCHYBAR_TEMPLATE"
