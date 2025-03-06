templates="$1"
source "os.sh"

if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

sketchybar_folders=("$dotfiles_directory/.config/sketchybar" "$dotfiles_directory/.config/bottombar" "$dotfiles_directory/.config/leftbar" "$dotfiles_directory/.config/rightbar")
templates_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_directory="$(dirname $templates_directory)"
plugins_folder="$dotfiles_directory/.config/sketchybar/plugins"

# kill all processes
pkill bottombar
pkill leftbar
pkill rightbar

COUNTER=0

for template in $templates; do
    sketchybar_folder="${sketchybar_folders[$COUNTER]}"
    sketchybarrc_path="$sketchybar_folder/sketchybarrc"
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

    cp -f "$sketchybar_template_path" "$sketchybarrc_path"
    echo "Copied $sketchybar_template_path to $sketchybarrc_path."

    echo "BAR NAME: $bar_name"
    # spawn new process of $bar_name

    # if [ ! "$bar_name" == "sketchybar" ]; then
    #     $bar_name &
    # fi

    COUNTER=$((COUNTER + 1))

done
