#!/bin/bash

source "../dotfiles.sh"

dir="$PWD/.tmux"
dotfiles=$(get_dotfiles $dir)
destination_directory="$HOME"

move_dotfiles "${dotfiles[@]}" "${destination_directory}"