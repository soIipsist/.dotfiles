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

sketchybar_config_folders=("sketchybar" "bottombar" "leftbar" "rightbar")

for folder in "${sketchybar_config_folders[@]}"; do
    sketchybar_config_folder="$dotfiles_directory/.config/$folder"
    mkdir -p "$sketchybar_config_folder"

    # Create symlinks
    if [[ "$folder" == "sketchybar" ]]; then
        mkdir -p "$plugins_directory"
        echo "Created: $plugins_directory."
    else
        symlink_target="$(dirname "$(which sketchybar)")/$folder"
        sketchybar_bin="$(which sketchybar)"

        # Check if symlink exists and if it points to the correct file
        if [[ -L "$symlink_target" ]]; then
            if [[ "$(readlink "$symlink_target")" != "$sketchybar_bin" ]]; then
                echo "Updating symlink: $symlink_target -> $sketchybar_bin"
                ln -sf "$sketchybar_bin" "$symlink_target"
            fi
        else
            echo "Creating new symlink: $symlink_target -> $sketchybar_bin"
            ln -s "$sketchybar_bin" "$symlink_target"
        fi
    fi
done
