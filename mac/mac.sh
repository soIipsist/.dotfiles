#!/bin/bash
source "../json.sh"
source "../os.sh"

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
        brewfile_path=$(pwd)/Brewfile
    fi

    echo $brewfile_path
    # brew bundle --file $brewfile_path
}

get_dotfile_folders() {
    if [ -z "$1" ]; then
        dotfile_folders=$(ls -d .* | grep -v '^\.\.$' | grep -v '^\.$')
    else
        dotfile_folders=$1
    fi
    echo $dotfile_folders
}

install_dotfiles() {
    dotfile_folders=$1
    destination_directory=$2

    if [ -z "$2" ]; then
        echo "'destination directory' argument is required."
        return
    fi

    for folder in $1; do

        # Collect .sh scripts
        scripts=$(find "$folder" -maxdepth 1 -type f -name "*.sh" 2>/dev/null)

        # Collect dotfiles
        dotfiles=$(find "$folder" -maxdepth 1 -type f ! -name "*.sh" 2>/dev/null)

        for script in $scripts; do
            echo "Executing $script."
            # bash "$(pwd)/$script"
        done

        for dotfile in $dotfiles; do
            echo $dotfile
            # sudo -s cp $dotfile $destination_directory
        done
    done

}

install_homebrew

os=$(get_os)
hostname=$(get_json_value "hostname")
computer_name=$(get_json_value "computer_name")
local_hostname=$(get_json_value "local_hostname")
dotfiles=$(get_json_value "dotfiles")
default_shell=$(get_json_value "default_shell")
brewfile_path=$(get_json_value "brewfile_path")
wallpaper_path=$(get_json_value "wallpaper_path")

# install_brewfile
# set_hostname
# set_default_shell

dotfile_folders=$(get_dotfile_folders $dotfiles)
install_dotfiles "${dotfile_folders[@]}" $HOME
