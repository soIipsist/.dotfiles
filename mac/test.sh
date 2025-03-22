#!/bin/bash
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"
source "../json.sh"

SKETCHYBAR_TEMPLATE=$(get_json_value "SKETCHYBAR_TEMPLATE" "$GIT_DOTFILES_DIRECTORY/mac/.themes/main.json")
THEME="diane"

# source "./.sketchybar/sketchybar.sh" "${SKETCHYBAR_TEMPLATE[@]}"
# echo $SKETCHYBAR_TEMPLATE
# source "./.sketchybar/plugins/set_template.sh" "$SKETCHYBAR_TEMPLATE"

bash "./set_theme.sh" "$THEME"
