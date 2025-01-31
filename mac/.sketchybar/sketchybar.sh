destination_directory="$dotfiles_directory/.config/sketchybar"
plugins_directory="$destination_directory/plugins"
source_plugins_directory="$PWD/.sketchybar/plugins"

# copy plugins
cp -f "$source_plugins_directory/aerospace.sh" "$plugins_directory"
cp -f "$source_plugins_directory/battery.sh" "$plugins_directory"
cp -f "$source_plugins_directory/calendar.sh" "$plugins_directory"
cp -f "$source_plugins_directory/clock.sh" "$plugins_directory"
cp -f "$source_plugins_directory/cpu.sh" "$plugins_directory"
cp -f "$source_plugins_directory/front_app.sh" "$plugins_directory"
cp -f "$source_plugins_directory/icon_map_fn.sh" "$plugins_directory"
cp -f "$source_plugins_directory/media.sh" "$plugins_directory"
cp -f "$source_plugins_directory/space_windows.sh" "$plugins_directory"
cp -f "$source_plugins_directory/space.sh" "$plugins_directory"

echo $destination_directory
