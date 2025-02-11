#!/bin/bash
source "../json.sh"
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"

json_file="colors/colors_1.json"

set_json_value "red" "#FF0000" $json_file
set_json_value "red" "pink" $json_file
