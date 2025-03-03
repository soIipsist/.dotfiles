if [ ! -z "$theme" ]; then
    source "$dotfiles_directory/.config/colors/set_colors.sh" "$theme"
fi

pkill -x bottombar
sleep 0.5
bottombar &

aerospace reload-config
brew services restart borders

sketchybar --animate sin 7 --set reload icon.color.alpha=0.5 icon.color.alpha=1.0
