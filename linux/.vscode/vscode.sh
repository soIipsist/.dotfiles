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

get_extensions() {
    extensions=$(code --list-extensions)

    for extension in $extensions; do
        echo "\""$extension\",""
    done
}

extensions=$(get_json_value "recommendations" "$pwd/extensions.json")
install_extensions $extensions
