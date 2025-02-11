#!/bin/bash
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
extensions_path="$dir/extensions.json"
extensions=$(get_json_value "recommendations" $extensions_path)
install_extensions $extensions
