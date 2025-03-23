#!/bin/bash
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"
source "../json.sh"

venv_path=$(get_json_value "venv_path")
set_venv_flag=$(get_json_value "set_venv_path")
pip_packages=$(get_json_value "pip_packages")

set_venv_path "$venv_path" "$set_venv_flag"
install_pip_packages "$venv_path" "${pip_packages[@]}"
