#!/bin/bash

dir="$PWD/.bash"
dotfiles=$(get_dotfiles $dir)
destination_directory="$HOME"

move_dotfiles "${dotfiles[@]}" "${destination_directory}"
