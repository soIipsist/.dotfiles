#!/bin/bash
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"
source "../json.sh"

template=$(get_json_value "SKETCHYBAR_TEMPLATE" "$GIT_DOTFILES_DIRECTORY/mac/.colors/main.json")
echo $template

copy_plugins=0
source "./.sketchybar/templates/set_template.sh" "$template" "$copy_plugins"
