destination_directory="$dotfiles_directory/.config/sketchybar"
plugins_directory="$destination_directory/plugins"
source_plugins_directory="$PWD/.sketchybar/plugins"

# copy plugins
files=("aerospace.sh" "battery.sh" "calendar.sh" "clock.sh" "cpu.sh" "front_app.sh" "icon_map_fn.sh" "media.sh" "space_windows.sh" "space.sh")

for file in "${files[@]}"; do
    cp -f "$source_plugins_directory/$file" "$plugins_directory"
    chmod +x "$plugins_directory/$file"
done

echo $destination_directory
