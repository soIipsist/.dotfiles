THEME="$1"

get_theme_path() {
    if [ -z "$THEME" ]; then
        return 0
    fi

}
set_vscode_theme() {
    vscode_source_path="$dotfiles_directory/.config/vscode/vscode_settings.json"
    vscode_destination_path="$HOME/Library/Application Support/Code/User/settings.json"

    if [ -z "$1" ]; then
        vscode_source_path="$1" # if argument is defined, set it as vscode source path
    fi

    if [ -f "$vscode_source_path" ]; then
        envsubst <"$vscode_source_path" >"$vscode_destination_path"
    fi

}

set_autosuggest_color() {
    if [ -n "$ITERM2_AUTOSUGGEST_COLOR" ]; then # replace existing autosuggest color, if it exists
        zshrc_path="$dotfiles_directory/.zshrc"
        var_name="ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"
        new_value="fg=$ITERM2_AUTOSUGGEST_COLOR"

        if grep -q "^$var_name=" "$zshrc_path"; then
            sed -i '' "s|^$var_name=.*|$var_name=\"$new_value\"|" "$zshrc_path"
        else
            echo "$var_name=\"$new_value\"" >>"$zshrc_path"
        fi
    fi
}

set_tmux_theme() {
    tmux_config_path="$GIT_DOTFILES_DIRECTORY/mac/.tmux/.tmux.conf"
    tmux_destination_path="$HOME/.tmux/.tmux.conf"

    if [ -f "$tmux_config_path" ]; then
        envsubst <"$tmux_config_path" >"$tmux_destination_path"
    fi

}

export_colors() {

    colors_path="$dotfiles_directory/.config/colors/colors.sh"

    if [ -z "$1" ]; then
        colors_path="$1"
    fi

    echo "#!/bin/bash" >"$exported_colors"
    jq -r 'to_entries | .[] | 
  if (.value | type == "string") then 
    "export \(.key)=\"\(.value)\""
  else 
    "export \(.key)=\(.value)"
  end' "$theme_path" >>"$colors_path"

    source "$colors_path"
}
