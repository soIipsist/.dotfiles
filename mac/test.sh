#!/bin/bash
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"
source "../json.sh"

venv_path=$(get_json_value "venv_path")
set_venv_path "$venv_path"
