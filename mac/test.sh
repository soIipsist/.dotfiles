#!/bin/bash
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"
source "../json.sh"

os=$(get_os)
echo $os

val=$(get_json_value "wallpaper_path")
echo $val

# Example usage:
# default_shell_config=$(get_default_shell_path)
# echo "Default shell configuration file: $default_shell_config"

# install_homebrew_flag=$(get_json_value "install_homebrew")
# install_homebrew "$install_homebrew_flag"

# if command -v brew &>/dev/null; then
#     echo "Homebrew is already installed."
# fi
