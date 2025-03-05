#!/bin/bash
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"
source "../json.sh"

SKETCHYBAR_TEMPLATE=$(get_json_value "SKETCHYBAR_TEMPLATE" "$GIT_DOTFILES_DIRECTORY/mac/.colors/main.json")
export COPY_PLUGINS=1

source "./.sketchybar/sketchybar.sh" "$SKETCHYBAR_TEMPLATE"

# source "./.sketchybar/templates/set_template.sh" "${templates[@]}"
