if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
    GIT_DOTFILES_DIRECTORY="$HOME/repos/soIipsist/.dotfiles"
fi

source "$dotfiles_directory/.config/themes/theme.sh"

aerospace reload-config
brew services restart borders

# if [ -z "$SELECTED_THEME" ]; then
#     SELECTED_THEME="main"
# fi

# echo "SELECTED THEME: $SELECTED_THEME" >>/tmp/debug.txt
# source "$GIT_DOTFILES_DIRECTORY/mac/set_theme.sh" "$SELECTED_THEME"
sketchybar --animate sin 7 --set reload icon.color.alpha=0.5 icon.color.alpha=1.0
