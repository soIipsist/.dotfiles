#!/bin/bash
source "../json.sh"
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"

install_homebrew() {
    # check if homebrew is not in $PATH
    if [[ ":$PATH:" == *":/opt/homebrew/bin:"* ]]; then
        echo "Homebrew was already installed."
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        echo "export PATH=/opt/homebrew/bin:$PATH" >>~/.zshrc
        source ~/.zshrc
    fi
}

install_brewfile() {
    if [ -z $brewfile_path ]; then
        return
    fi

    brew bundle --file $brewfile_path
}

install_pip_packages() {
    pip_packages=$1

    if [ -z "$pip_packages" ]; then
        return
    fi

    # create venv if it doesn't exist
    cd $HOME
    if [ ! -d "$HOME/venv" ]; then
        python -m venv venv
    fi

    source venv/bin/activate

    for package in $pip_packages; do
        pip install $package
    done

}

install_homebrew

os=$(get_os)
git_username=$(get_json_value "git_username")
git_email=$(get_json_value "git_email")
hostname=$(get_json_value "hostname")
computer_name=$(get_json_value "computer_name")
local_hostname=$(get_json_value "local_hostname")
dotfiles=$(get_json_value "dotfiles")
dotfiles_directory=$(get_json_value "dotfiles_directory" "" "$HOME") # will be $HOME by default
scripts=$(get_json_value "scripts")
excluded_scripts=$(get_json_value "excluded_scripts")
pip_packages=$(get_json_value "pip_packages")
git_repos=$(get_json_value "git_repos")
git_home_path=$(get_json_value "git_home_path")
default_shell=$(get_json_value "default_shell")
brewfile_path=$(get_json_value "brewfile_path")
color_scheme=$(get_json_value "color_scheme")
wallpaper_path=$(get_json_value "wallpaper_path")

install_brewfile
set_hostname
set_default_shell
install_pip_packages "${pip_packages[@]}"

install_dotfiles "$dotfiles_directory" "$dotfiles" "$scripts" "$excluded_scripts"
git_config "$git_username" "$git_email"
clone_git_repos "${git_repos[@]}" "$git_home_path"

if [ -n "$wallpaper_path" ]; then
    osascript prefs.scpt $wallpaper_path
fi
