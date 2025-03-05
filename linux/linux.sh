#!/bin/bash
source "../json.sh"
source "../dotfiles.sh"
source "../git.sh"
source "../os.sh"
source "../wallpaper.sh"

install_zoxide() {
    if [ -z "$1" ] || [ "$1" == false ]; then
        return
    fi

    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

    if ! grep -q 'eval "$(zoxide init bash)"' "$shell_path"; then
        echo 'eval "$(zoxide init bash)"' >>"$shell_path"
    fi

    sudo mv ~/.local/bin/zoxide /usr/local/bin/
}
dotfile_args=("$@")

hostname=$(get_json_value "hostname")
apt_packages=$(get_json_value "apt_packages")
dotfiles=$(get_json_value "dotfiles" "" "${dotfile_args[@]}")        # dotfiles argument will be used by default
dotfiles_directory=$(get_json_value "dotfiles_directory" "" "$HOME") # will be $HOME by default
scripts=$(get_json_value "scripts")
excluded_scripts=$(get_json_value "excluded_scripts")
git_username=$(get_json_value "git_username")
git_email=$(get_json_value "git_email")
git_home=$(get_json_value "git_home")
git_repos=$(get_json_value "git_repos")

wallpaper_path=$(replace_root "$(get_json_value "wallpaper_path")" "$GIT_DOTFILES_DIRECTORY")
lockscreen_path=$(replace_root "$(get_json_value "lockscreen_path")" "$GIT_DOTFILES_DIRECTORY")

install_homebrew_flag=$(get_json_value "install_homebrew")
install_zoxide_flag=$(get_json_value "install_zoxide")
brew_packages=$(get_json_value "brew_packages")
brew_cask_packages=$(get_json_value "brew_cask_packages")

install_homebrew "$install_homebrew_flag"
install_zoxide "$install_zoxide_flag"
set_hostname "$hostname"
install_brew_packages "$brew_packages" "$brew_cask_packages"

apt_packages_array=($apt_packages)
sudo apt install --yes --no-install-recommends "${apt_packages_array[@]}"

install_dotfiles "$dotfiles_directory" "$dotfiles" "$scripts" "$excluded_scripts"
git_config "$git_username" "$git_email"
clone_git_repos "${git_repos[@]}" "$git_home"
set_lockscreen_and_wallpaper "$wallpaper_path" "$lockscreen_path"
