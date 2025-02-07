destination_directory="$dotfiles_directory/.config/sketchybar"
plugins_directory="$destination_directory/plugins"
source_plugins_directory="$PWD/.sketchybar/plugins"

# copy plugins
files=($(ls $source_plugins_directory))

for file in "${files[@]}"; do
    cp -f "$source_plugins_directory/$file" "$plugins_directory"
    chmod +x "$plugins_directory/$file"
done

echo $destination_directory
