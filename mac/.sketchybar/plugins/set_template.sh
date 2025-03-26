function set_sketchybar_template() {
    templates="$1"
    COUNTER=0

    pkill bottombar
    pkill rightbar
    pkill leftbar

    SKETCHYBAR_DIR="$GIT_DOTFILES_DIRECTORY/mac/.sketchybar"
    sketchybar_config_folders=(sketchybar "bottombar" "leftbar" "rightbar")
    positions=(top bottom left right)

    for template in $templates; do

        sketchybar_config_folder="$dotfiles_directory/.config/${sketchybar_config_folders[$COUNTER]}"
        sketchybarrc_path="$sketchybar_config_folder/sketchybarrc"
        sketchybar_template_path="$SKETCHYBAR_DIR/templates/$template"
        bar_name=$(basename "$sketchybar_config_folder")
        position="${positions[$COUNTER]}"

        mkdir -p "$sketchybar_config_folder"
        echo $'\n'"Setting $bar_name template: $template."

        if [ ! -f "$sketchybar_template_path" ]; then
            echo "Sketchybar template $sketchybar_template_path does not exist!"
            COUNTER=$((COUNTER + 1))
            continue
        fi

        cp -f "$sketchybar_template_path" "$sketchybarrc_path"

        echo "Copied $sketchybar_template_path to $sketchybarrc_path."

        # replace dotfiles_directory
        envsubst '${dotfiles_directory},${GIT_DOTFILES_DIRECTORY}' <"$sketchybarrc_path" >"$sketchybarrc_path.tmp" && mv "$sketchybarrc_path.tmp" "$sketchybarrc_path"

        # set bar position
        sed -i '' "/^sketchybar --bar/ s/position=[^ ]*/position=$position/" "$sketchybarrc_path"

        # spawn new process of $bar_name
        if [ "$bar_name" = "sketchybar" ]; then
            brew services restart sketchybar
        else
            # replace 'sketchybar' keyword with 'bar_name'
            sed -i '' "s/sketchybar/$bar_name/g" "$sketchybarrc_path"
            "$bar_name" &
        fi

        if command -v "$bar_name" >/dev/null 2>&1; then
            "$bar_name" --reload
        else
            echo "Error: $bar_name is not an executable."
        fi

        COUNTER=$((COUNTER + 1))

    done

}
