#!/bin/bash

source "../dotfiles.sh"


dir="$PWD/.terminal"
dotfiles=$(get_dotfiles $dir)
destination_directory="$HOME"

# echo $HOME
move_dotfiles "${dotfiles[@]}" "${destination_directory}"
