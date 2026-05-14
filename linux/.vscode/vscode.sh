#!/bin/bash
source "../json.sh"

dir="$PWD/.vscode"
extensions_path="$dir/extensions.json"
extensions=$(get_json_value "recommendations.extensions" $extensions_path)

if ! command -v code &>/dev/null; then
    export PATH="$PATH:/usr/share/code/bin"
fi

for extension in $extensions; do
    code --install-extension $extension --force
done
