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

dir="$PWD/.vscode"
extensions_path="$dir/settings/extensions.json"
settings_path="$dir/settings/settings.json"
default_vs_code_path="$HOME/Library/Application Support/Code/User"

extensions=$(get_json_value "recommendations" $extensions_path "")
echo "$extensions"
# install_extensions $extensions
