if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

# create symbolic link for bottom bar
# ln -s $(which sketchybar) $(dirname $(which sketchybar))/bottombar

dirs=("$dotfiles_directory/.config/sketchybar" "$dotfiles_directory/.config/bottombar")
plugins_directory="$PWD/.sketchybar/plugins"
templates_directory="$PWD/.sketchybar/templates"

for dir in "${dirs[@]}"; do

    if [ ! -d "$dir" ]; then
        echo "Created: $dir"
        mkdir -p "$dir"
    fi
    if [ ! -d "$dir/plugins" ]; then
        echo "Created: $dir/plugins"
        mkdir -p "$dir/plugins"
    fi

    for file in "$PWD/.sketchybar/plugins"/*; do
        cp -f "$file" "$dir/plugins"
        chmod +x "$dir/plugins/$(basename "$file")"
    done
done

source "$templates_directory/sketchybarrc.sh"
