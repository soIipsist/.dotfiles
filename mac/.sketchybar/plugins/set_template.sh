if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKETCHYBAR_DIR="$(dirname $SCRIPT_DIR)"
config_folders=("$dotfiles_directory/.config/sketchybar" "$dotfiles_directory/.config/bottombar" "$dotfiles_directory/.config/leftbar" "$dotfiles_directory/.config/rightbar")

set_template() {
    # copies sketchybarrc based on the index of the template (e.g bottombar will be the second in $SKETCHYBAR_TEMPLATE array)

    config_folder="$1"
    template="$2"

    sketchybarrc_path="$config_folder/sketchybarrc"
    bar_name=$(basename $config_folder)

    echo $'\n'"Setting $bar_name template: $template."
    sketchybar_template_path="$SCRIPT_DIR/$template"

    # check if sketchybar folder exists
    if [ ! -d "$config_folder" ]; then
        mkdir -p "$config_folder"
        echo "Created $config_folder."
    fi

    cp -f "$sketchybar_template_path" "$sketchybarrc_path"
    echo "Copied $sketchybar_template_path to $sketchybarrc_path."

    echo "BAR NAME: $bar_name"

    # spawn new process of $bar_name

    # if [ ! "$bar_name" == "sketchybar" ]; then
    #     $bar_name &
    # fi

}

# kill all processes
pkill bottombar
pkill leftbar
pkill rightbar

templates="$1"
COUNTER=0

for template in $templates; do

    config_folder="${config_folders[$COUNTER]}"
    set_template "$config_folder" "$template"

    COUNTER=$((COUNTER + 1))

done
