#!/bin/bash
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"
source "../json.sh"

templates=($(get_json_value "SKETCHYBAR_TEMPLATE" "$GIT_DOTFILES_DIRECTORY/mac/.colors/main.json"))
for template in "${templates[@]}"; do
    echo "TEMPL $template"
done
export COPY_PLUGINS=1
# source "./.sketchybar/templates/set_template.sh"
