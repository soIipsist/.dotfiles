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
        chmod +x "$file"
    done
done

if [ -z "$sketchybar_template" ]; then
    sketchybar_template="main"
fi

# copy sketchybar template, if it the template path exists
if [ -f "$templates_directory/$sketchybar_template" ]; then
    cp -f "$templates_directory/$sketchybar_template" "$dotfiles_directory/.config/sketchybar/sketchybarrc"
    sketchybar --reload
else
    # copy bottom and top parts
    cp -f "$templates_directory/bottom_$sketchybar_template" "$dotfiles_directory/.config/bottombar/sketchybarrc"
    cp -f "$templates_directory/top_$sketchybar_template" "$dotfiles_directory/.config/sketchybar/sketchybarrc"

    sketchybar --reload
    bottombar --reload
fi
