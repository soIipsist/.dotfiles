#!/bin/bash
source "../json.sh"
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"

set_json_value "red" "#FF0000" "colors.json"

set_json_value "red" "pink" "colors.json"
set_json_value "blue" "pink" "colors.json"
