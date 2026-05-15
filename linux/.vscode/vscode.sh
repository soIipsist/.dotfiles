#!/bin/bash
source "../json.sh"

dir="$PWD/.vscode"
extensions_path="$dir/extensions.json"
extensions=$(get_json_value "recommendations.extensions" $extensions_path)
install_extensions=$(get_json_value "install_vscode_extensions")

if ! command -v code &>/dev/null; then
    export PATH="$PATH:/usr/share/code/bin"
fi


if [ "$install_extensions" = "true" ]; then
    for extension in $extensions; do
        code --install-extension "$extension" --force >&2
    done
fi

