#!/bin/bash
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"
source "../json.sh"

SKETCHYBAR_TEMPLATE=$(get_json_value "SKETCHYBAR_TEMPLATE" "$GIT_DOTFILES_DIRECTORY/mac/.colors/main.json")
export COPY_PLUGINS=0

# source "./.sketchybar/sketchybar.sh" "$SKETCHYBAR_TEMPLATE"

# source "./.sketchybar/templates/set_template.sh" "${templates[@]}"
echo_line_to_file "hello world" "./.sketchybar/templates/xrce_bottom" 2
