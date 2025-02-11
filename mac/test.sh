#!/bin/bash
source "../json.sh"
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"

vals=("hello" "goodbye")
# vals="red"

excluded_scripts=$(get_json_value "excluded_scripts")
scripts=$(get_json_value "scripts")
dotfiles=$(get_json_value "dotfiles")

echo "${excluded_scripts[@]}"
