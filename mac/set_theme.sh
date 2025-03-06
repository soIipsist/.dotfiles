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

export_theme() {
    theme_path="$1" # some theme.json file
    icons_path="$(dirname $theme_path)/icons.json"

    theme_colors_path="$dotfiles_directory/.config/themes/theme.sh"

    if [ ! -f "$theme_colors_path" ]; then
        touch "$theme_colors_path"
    fi

    echo "#!/bin/bash" >"$theme_colors_path"
    jq -r 'to_entries | .[] | 
  if (.value | type == "string") then 
    "export \(.key)=\"\(.value)\""
  elif (.value | type == "array") then 
    "export \(.key)=\"" + (.value | join(" ")) + "\""
  else 
    "export \(.key)=\(.value)"
  end' "$theme_path" >>"$theme_colors_path"

    jq -r 'to_entries | .[] | 
  if (.value | type == "string") then 
    "export \(.key)=\"\(.value)\""
  elif (.value | type == "array") then 
    "export \(.key)=\"" + (.value | join(" ")) + "\""
  else 
    "export \(.key)=\(.value)"
  end' "$icons_path" >>"$theme_colors_path"

    source "$theme_colors_path"
}

set_sketchybar_template() {

    # set sketchybar template only if set_template exists in sketchybar folder

    set_template_path="$dotfiles_directory/.config/sketchybar/plugins/set_template.sh"

    if [ ! -f "$set_template_path" ]; then
        echo "sketchybar: set_template.sh does not exist, run with .sketchybar."
        return 0
    fi

    if [ -n "$SKETCHYBAR_TEMPLATE" ]; then
        source "$set_template_path" "$SKETCHYBAR_TEMPLATE"
    fi
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
    set_templates_path="$dotfiles_directory/.config/sketchybar/plugins/set_template.sh"

    # make sure /themes exists
    mkdir -p "$dotfiles_directory/.config/themes"

    # export and source colors to get all variables
    export_theme "$theme_path"
    source "$colors_path"
    WALLPAPER_PATH=$(replace_root "$WALLPAPER_PATH" "$GIT_DOTFILES_DIRECTORY")
    SKETCHYBAR_TEMPLATE=("$SKETCHYBAR_TEMPLATE")

    set_wallpaper_mac "$WALLPAPER_PATH"
    set_autosuggest_color
    set_sketchybar_template

    echo "Theme was changed to $theme."

}
