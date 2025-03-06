if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

source "$dotfiles_directory/.config/themes/theme.sh"
sleep 0.5

aerospace reload-config
brew services restart borders
brew services restart sketchybar

sketchybar --animate sin 7 --set reload icon.color.alpha=0.5 icon.color.alpha=1.0
