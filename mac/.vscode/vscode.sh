source "../json.sh"

destination_directory="$dotfiles_directory/.config/vscode"

install_extensions() {
    if [ -z "$1" ]; then
        echo "VSCode extensions not defined."
        return
    fi

}

source_directory="$PWD/.vscode"
extensions_path="$source_directory/extensions.json"
settings_path="$source_directory/settings.json"
default_vs_code_path="$HOME/Library/Application Support/Code/User"

extensions=$(get_json_value "recommendations" $extensions_path "")

for extension in $extensions; do
    bash code --install-extension $extension --force
done

echo $destination_directory

# cp -f "$settings_path" "$default_vs_code_path"
