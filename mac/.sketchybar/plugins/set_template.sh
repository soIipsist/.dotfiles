if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

# kill all processes
pkill bottombar
pkill leftbar
pkill rightbar

templates="$1"
COUNTER=0

if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
    GIT_DOTFILES_DIRECTORY="$HOME/repos/soIipsist/.dotfiles"
fi

SKETCHYBAR_DIR="$GIT_DOTFILES_DIRECTORY/mac/.sketchybar"
sketchybar_config_folders=(sketchybar "bottombar" "leftbar" "rightbar")

for template in $templates; do

    sketchybar_config_folder="$dotfiles_directory/.config/${sketchybar_config_folders[$COUNTER]}"
    sketchybarrc_path="$sketchybar_config_folder/sketchybarrc"
    sketchybar_template_path="$SKETCHYBAR_DIR/templates/$template"
    bar_name=$(basename "$sketchybar_config_folder")

    mkdir -p "$sketchybar_config_folder"

    echo $'\n'"Setting $bar_name template: $template."

    if [ ! -f "$sketchybar_template_path" ]; then
        echo "Sketchybar template $sketchybar_template_path does not exist!"
        continue
    fi

    cp -f "$sketchybar_template_path" "$sketchybarrc_path"
    echo "Copied $sketchybar_template_path to $sketchybarrc_path."

    # spawn new process of $bar_name
    if [ "$bar_name" = "sketchybar" ]; then
        brew services restart sketchybar
    else
        # replace 'sketchybar' with 'bar_name'
        sed -i '' "s/sketchybar /$bar_name /g" "$sketchybarrc_path"
        "$bar_name" &
    fi

    if command -v "$bar_name" >/dev/null 2>&1; then
        "$bar_name" --reload
    else
        echo "Error: $bar_name is not an executable."
    fi

    COUNTER=$((COUNTER + 1))

done
