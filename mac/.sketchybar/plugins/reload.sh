if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

source "$dotfiles_directory/.config/colors/set_colors.sh" "$theme"
sleep 0.5

aerospace reload-config
brew services restart borders

sketchybar --animate sin 7 --set reload icon.color.alpha=0.5 icon.color.alpha=1.0
