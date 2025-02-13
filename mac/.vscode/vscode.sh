source "../json.sh"

install_extensions() {
    if [ -z "$1" ]; then
        echo "VSCode extensions not defined."
        return
    fi

    for extension in $extensions; do
        code --install-extension $extension --force
    done
}

create_settings_file() {
    source_path="$1"
    destination_path="$2"

    # create vscode settings file with new environment variables
    source "$HOME/.config/colors/colors.sh" # replace with $dotfiles_directory

    echo "DEBUG: $VSCODE_SIDEBAR_BACKGROUND" >/tmp/debug.txt
    envsubst <"$source_path" >"$destination_path"

}

destination_directory="$PWD/.vscode"
extensions_path="$destination_directory/settings/extensions.json"
settings_path="$destination_directory/settings/settings.json"
default_vs_code_path="$HOME/Library/Application Support/Code/User"

extensions=$(get_json_value "recommendations" $extensions_path "")
install_extensions $extensions
create_settings_file "$settings_path" "$destination_path"
