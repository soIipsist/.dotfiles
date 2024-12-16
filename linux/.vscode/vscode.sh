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
json_file="$dir/extensions.json"
extensions=$(get_json_value "recommendations")
install_extensions $extensions
