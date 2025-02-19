#!/bin/bash
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"
source "../json.sh"

echo "$BORDER_WIDTH"

value=$(get_json_value "COLOR_SCHEME_NAME" "$HOME/.config/colors/colors_1.json")
echo $value
