templates="$1"

echo_line_to_file() {
    local line="$1"
    local file_path="$2"
    local line_number="$3"

    if [ ! -f $file_path ]; then
        echo "File $file_path does not exist"
        return
    fi

    # If line_number is empty, append to the bottom
    if [[ -z "$line_number" ]]; then
        echo "$line" >>"$file_path"
    else
        # Insert line at specific line_number
        sed -i "" "${line_number}i\\
$line
" "$file_path"
    fi
}

if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

sketchybar_folders=("$dotfiles_directory/.config/sketchybar" "$dotfiles_directory/.config/bottombar" "$dotfiles_directory/.config/leftbar" "$dotfiles_directory/.config/rightbar")
templates_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_directory="$(dirname $templates_directory)"
plugins_folder="$source_directory/plugins"

# kill all processes
pkill bottombar
pkill leftbar
pkill rightbar

COUNTER=0

for template in $templates; do
    sketchybar_folder="${sketchybar_folders[$COUNTER]}"
    sketchybarrc_path="$sketchybar_folder/sketchybarrc"
    sketchybar_plugins_folder="$sketchybar_folder/plugins"
    bar_name=$(basename $sketchybar_folder)

    echo $'\n'"Setting $bar_name template: $template."
    sketchybar_template_path="$templates_directory/$template"

    # check if sketchybar folder exists
    if [ ! -d "$sketchybar_folder" ]; then
        mkdir -p "$sketchybar_folder"
        echo "Created $sketchybar_folder."
    fi

    if [ ! -d "$sketchybar_plugins_folder" ]; then
        mkdir -p "$sketchybar_plugins_folder"
        echo "Created $sketchybar_plugins_folder."
    fi

    # copy all plugins
    if [ $COPY_PLUGINS -eq 1 ]; then

        for file in "$plugins_folder"/*; do
            original_name=$(basename $file)

            if [ ! "$bar_name" == "sketchybar" ]; then
                # Create a temporary file with 'sketchybar' replaced with 'bottombar'
                temp_file=$(mktemp)
                sed "s/sketchybar/$bar_name/g" "$file" >"$temp_file"
                file="$temp_file"
            fi

            cp -f "$file" "$sketchybar_plugins_folder/$original_name"
            echo "Copied $file to $sketchybar_plugins_folder/$original_name."

            chmod +x "$sketchybar_plugins_folder/$original_name"

            if [ -f "$temp_file" ]; then
                rm -f "$temp_file"
            fi
        done
    fi

    cp -f "$sketchybar_template_path" "$sketchybarrc_path"

    # append "source colors.sh" and $PLUGIN_DIR
    colors_path="$dotfiles_directory/.config/colors/colors.sh"
    echo $'\n'"Colors path: $colors_path."
    echo "Plugins directory: $sketchybar_plugins_folder"

    echo_line_to_file "source \"$colors_path\"" "$sketchybarrc_path" 1
    echo_line_to_file "PLUGIN_DIR=\"$sketchybar_plugins_folder\"" "$sketchybarrc_path" 2

    echo "Copied $sketchybar_template_path to $sketchybarrc_path."

    # spawn new process of $bar_name

    if [ ! "$bar_name" == "sketchybar" ]; then
        $bar_name &
    fi

    COUNTER=$((COUNTER + 1))

done
