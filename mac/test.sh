#!/bin/bash
source "../json.sh"
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"

excluded_scripts=$(get_json_value "excluded_scripts")

script="script.sh"

if [[ " ${excluded_scripts[*]} " =~ " ${script} " ]]; then
    echo $script
fi

echo "${excluded_scripts[@]}"

dotfiles_directory="$HOME/temp"
install_dotfiles $dotfiles_directory
