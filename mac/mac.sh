#!/bin/bash
source "../json.sh"

source "../os.sh"

install_homebrew() {
    # check if homebrew is not in $PATH
    if [[ ":$PATH:" == *"/opt/home:"* ]]; then
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

is_array() {
    local var_name="$1"
    if [[ "$(declare -p "$var_name" 2>/dev/null)" =~ "declare -a" ]]; then
        # echo "is array"
        return 0 # True, it's an array
    else
        # echo "not array"
        return 1 # False, it's not an array
    fi
}

get_dotfiles() {
    if is_array $1; then
        echo "${dotfiles[@]}"
        return
    else
        cd "$1"
        f=$(ls -d .* 2>/dev/null | grep -v '^\.\.$' | grep -v '^\.$')
        dotfiles=()
        for variable in $f; do
            dotfiles+=("$1/$variable")
        done
    fi

    printf '%s\n' "${dotfiles[@]}"
}

move_dotfiles() {
    if [ -z "$1" ]; then
        echo "'dotfiles' argument is required."
        return
    fi

    if [ -z "$2" ]; then
        echo "'destination directory' argument is required."
        return
    fi

    if [[ "$3" =~ ^[0-1]$ ]]; then
        copy=$3
    else
        copy=1
    fi

    dotfiles=$1

    for dotfile in $dotfiles; do
        if [ "$copy" -eq 1 ]; then
            sudo -s cp $dotfile $2
        else
            sudo -s mv $dotfile $2
        fi

    done

}

install_dotfiles() {
    if [ -z "$1" ]; then
        dotfile_folders=$(ls -d .* | grep -v '^\.\.$' | grep -v '^\.$')
    else
        dotfile_folders=$1
    fi

    for folder in $dotfile_folders; do
        scripts=$(ls "$folder"/*.sh 2>/dev/null)
        for script in $scripts; do
            echo "Executing $script."
            bash "$(pwd)/$script"
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

install_brewfile
set_hostname
set_default_shell
install_dotfiles $dotfiles

if [ ! -z $wallpaper_path ]; then
    osascript prefs.scpt $wallpaper_path
fi
