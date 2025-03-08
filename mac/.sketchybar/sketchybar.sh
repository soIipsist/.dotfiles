if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

# copy plugins to /sketchybar/plugins
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source_plugins_directory="$SCRIPT_DIR/plugins"

sketchybar_names=("sketchybar" "bottombar" "leftbar" "rightbar")

for bar_name in "${sketchybar_names[@]}"; do
    sketchybar_config_folder="$dotfiles_directory/.config/$bar_name"
    sketchybar_plugins_directory="$dotfiles_directory/.config/$bar_name/plugins"
    mkdir -p "$sketchybar_config_folder"
    echo "Created $sketchybar_config_folder."
    mkdir -p "$sketchybar_plugins_directory"
    echo "Created $sketchybar_plugins_directory."

    # remove all existing plugins
    rm "$sketchybar_plugins_directory"/*.sh

    # create plugins dir
    for file in "$source_plugins_directory"/*; do
        original_name=$(basename $file)
        dest_plugin="$sketchybar_plugins_directory/$original_name"
        cp -f "$file" "$dest_plugin"

        # replace 'sketchybar' keyword with 'bar_name'

        if [[ "$bar_name" != "sketchybar" ]]; then
            sed -i '' "s/sketchybar /$bar_name /g" "$dest_plugin"
        fi

        chmod +x "$dest_plugin"
    done

    # Create symlinks for sketchybar folders (besides sketchybar)

    if [[ "$bar_name" != "sketchybar" ]]; then
        symlink_target="$(dirname "$(which sketchybar)")/$bar_name"
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
