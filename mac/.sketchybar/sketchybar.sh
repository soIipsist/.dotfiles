destination_directory="$dotfiles_directory/.config/sketchybar"
plugins_directory="$destination_directory/plugins"

# copy plugins
cp -f "aerospace.sh" "$plugins_directory"
cp -f "battery.sh" "$plugins_directory"
cp -f "calendar.sh" "$plugins_directory"
cp -f "cpu.sh" "$plugins_directory"
cp -f "front_app.sh" "$plugins_directory"
cp -f "icon_map_fn.sh" "$plugins_directory"
cp -f "media.sh" "$plugins_directory"
cp -f "space_windows.sh" "$plugins_directory"
cp -f "space.sh" "$plugins_directory"

echo $destination_directory
