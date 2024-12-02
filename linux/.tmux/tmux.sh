#!/bin/bash

dir="$PWD/.tmux"
dotfiles=$(get_dotfiles $dir)
destination_directory="$HOME/Desktop/test"

move_dotfiles "${dotfiles[@]}" "${destination_directory}"
