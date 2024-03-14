#!/bin/bash
source "../json.sh"
source "../dotfiles.sh"
source "../os.sh"
source "brew.sh"

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
