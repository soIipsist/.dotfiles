#!/bin/bash
source "../json.sh"
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"

install_brewfile() {
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
pip_packages=$(get_json_value "pip_packages")
git_repos=$(get_json_value "git_repos")
git_home=$(get_json_value "git_home")
default_shell=$(get_json_value "default_shell")
brewfile_path=$(get_json_value "brewfile_path")
color_preset=$(get_json_value "color_preset" "" "main")     # main color preset used my default
sketchybar_template=$(get_json_value "sketchybar_template") # default sketchybar layout will be 'main'
wallpaper_path=$(get_json_value "wallpaper_path")
wallpaper_path=$(replace_root $wallpaper_path $GIT_DOTFILES_DIRECTORY)
install_homebrew_flag=$(get_json_value "install_homebrew")
brew_packages=$(get_json_value "brew_packages")
brew_cask_packages=$(get_json_value "brew_cask_packages")

if [ -n "$dotfile_args" ]; then
    dotfiles="${dotfile_args[@]}"
fi

install_homebrew "$install_homebrew_flag"
install_brew_packages "$brew_packages" "$brew_cask_packages"
install_brewfile "$brewfile_path"
set_hostname "$hostname"
set_default_shell
install_pip_packages "${pip_packages[@]}"

install_dotfiles "$dotfiles_directory" "$dotfiles" "$scripts" "$excluded_scripts"
git_config "$git_username" "$git_email"
clone_git_repos "${git_repos[@]}" "$git_home"

if [ -n "$wallpaper_path" ]; then
    osascript prefs.scpt $wallpaper_path
fi
