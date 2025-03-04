#!/bin/bash
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"
source "../json.sh"

template=$(get_json_value "SKETCHYBAR_TEMPLATE" "$GIT_DOTFILES_DIRECTORY/mac/.colors/main.json")
echo $template

source "./.sketchybar/templates/set_template.sh" $template
