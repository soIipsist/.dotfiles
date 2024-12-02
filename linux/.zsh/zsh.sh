#!/bin/bash

dir="$PWD/.zsh"
dotfiles=$(get_dotfiles $dir)
destination_directory="$HOME"

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
move_dotfiles "${dotfiles[@]}" "${destination_directory}"
