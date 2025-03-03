if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

if [ -z "$SKETCHYBAR_TEMPLATE" ]; then
    SKETCHYBAR_TEMPLATE="main"
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
        original_name=$(basename $file)

        if [ "$dir" == "$dotfiles_directory/.config/bottombar" ]; then
            # Create a temporary file with 'sketchybar' replaced with 'bottombar'
            temp_file=$(mktemp)
            sed 's/sketchybar/bottombar/g' "$file" >"$temp_file"
            file="$temp_file"
        fi

        cp -f "$file" "$dir/plugins/$original_name"
        chmod +x "$dir/plugins/$original_name"

        if [ -f "$temp_file" ]; then
            rm -f "$temp_file"
        fi
    done
done

source "$templates_directory/set_template.sh" "$SKETCHYBAR_TEMPLATE"
