source "../os.sh"
source "../wallpaper.sh"

set_autosuggest_color() {
    if [ -z "$ITERM2_AUTOSUGGEST_COLOR" ]; then # replace existing autosuggest color, if it exists
        return 0
    fi

    zshrc_path="$dotfiles_directory/.zshrc"
    var_name="ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"
    new_value="fg=$ITERM2_AUTOSUGGEST_COLOR"

    if grep -q "^$var_name=" "$zshrc_path"; then
        sed -i '' "s|^$var_name=.*|$var_name=\"$new_value\"|" "$zshrc_path"
    else
        echo "$var_name=\"$new_value\"" >>"$zshrc_path"
    fi
}

export_colors() {
    theme_path="$1"
    theme_colors_path="$dotfiles_directory/.config/themes/theme.sh"

    mkdir -p "$(dirname $theme_colors_path)"
    touch "$theme_colors_path"

    echo "#!/bin/bash" >"$theme_colors_path"
    jq -r 'to_entries | .[] | 
  if (.value | type == "string") then 
    "export \(.key)=\"\(.value)\""
  else 
    "export \(.key)=\(.value)"
  end' "$theme_path" >>"$theme_colors_path"

    source "$theme_colors_path"
}

set_theme() {
    theme="$1"

    if [ -z $theme ]; then
        return 0
    fi
    if [ -z "$dotfiles_directory" ]; then
        dotfiles_directory="$HOME"
    fi
    theme_path="$dotfiles_directory/.config/themes/$theme.json"
    colors_path="$dotfiles_directory/.config/themes/theme.sh"
    templates_directory="$GIT_DOTFILES_DIRECTORY/mac/.sketchybar/templates"

    # export and source colors to get all variables
    export_colors "$theme_path"
    source "$colors_path"
    WALLPAPER_PATH=$(replace_root "$WALLPAPER_PATH" "$GIT_DOTFILES_DIRECTORY")

    set_wallpaper_mac "$WALLPAPER_PATH"
    set_autosuggest_color

    # set sketchybar template
    if [ -n "$SKETCHYBAR_TEMPLATE" ]; then
        source "$templates_directory/set_template.sh" "$SKETCHYBAR_TEMPLATE"
    fi

    echo "Theme was changed to $theme."

}
