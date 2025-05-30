#!/bin/bash
source "../json.sh"
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"
source "wallpaper.sh"
source "set_theme.sh"

install_from_brewfile() {
    brewfile_path="$1"

    if [ -z $brewfile_path ]; then
        return
    fi

    brew bundle --file $brewfile_path
}

dotfile_args=("$@")

git_username=$(get_json_value "git_username")
git_email=$(get_json_value "git_email")
hostname=$(get_json_value "hostname")
computer_name=$(get_json_value "computer_name")
local_hostname=$(get_json_value "local_hostname")
dotfiles=$(get_json_value "dotfiles" "" "${dotfile_args[@]}")        # dotfiles argument will be used by default
dotfiles_directory=$(get_json_value "dotfiles_directory" "" "$HOME") # will be $HOME by default
scripts=$(get_json_value "scripts")
excluded_scripts=$(get_json_value "excluded_scripts")
scripts_directory=$(get_json_value "scripts_directory")
venv_path=$(get_json_value "venv_path" "" "$VENV_PATH")
pip_packages=$(get_json_value "pip_packages")
git_repos=$(get_json_value "git_repos")
git_home=$(get_json_value "git_home")
default_shell=$(get_json_value "default_shell")
brewfile_path=$(get_json_value "brewfile_path")
theme=$(get_json_value "theme") # main color preset used my default
wallpaper_path=$(replace_root "$(get_json_value "wallpaper_path")" "$GIT_DOTFILES_DIRECTORY")
install_homebrew_flag=$(get_json_value "install_homebrew")
brew_packages=$(get_json_value "brew_packages")
brew_cask_packages=$(get_json_value "brew_cask_packages")

if [ -n "$dotfile_args" ]; then
    dotfiles="${dotfile_args[@]}"
fi

dotfiles_scripts_dir="$SCRIPT_DIR/scripts"
ORIGINAL_SCRIPT_DIR="$SCRIPT_DIR"

install_homebrew "$install_homebrew_flag"
install_from_brewfile "$brewfile_path"
install_brew_packages "$brew_packages" "$brew_cask_packages"
set_hostname "$hostname"
set_default_shell "$default_shell"
install_dotfiles "$dotfiles_directory" "$dotfiles" "$scripts" "$excluded_scripts"
copy_scripts "$dotfiles_scripts_dir" "$scripts_directory"

set_default_shell_variable "GIT_DOTFILES_DIRECTORY" "$ORIGINAL_SCRIPT_DIR"
set_default_shell_variable "SCRIPTS_DIRECTORY" "$scripts_directory"

git_config "$git_username" "$git_email"
clone_git_repos "${git_repos[@]}" "$git_home"
set_wallpaper "$wallpaper_path"
set_venv_path "$venv_path"
install_pip_packages "$venv_path" "${pip_packages[@]}"
set_theme "$theme"
