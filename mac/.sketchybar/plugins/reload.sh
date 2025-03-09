if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
    GIT_DOTFILES_DIRECTORY="$HOME/repos/soIipsist/.dotfiles"
fi

sketchybar --animate sin 7 --set reload icon.color.alpha=0.5 icon.color.alpha=1.0
source "$dotfiles_directory/.config/themes/theme.sh"

aerospace reload-config
brew services restart borders

# reload if process exists

# if [ -n $(pgrep "bottombar") ]; then
#     pkill bottombar
#     bottombar &
# fi

# if [ -n $(pgrep "leftbar") ]; then
#     pkill leftbar
#     leftbar &
# fi

# if [ -n $(pgrep "rightbar") ]; then
#     pkill rightbar
#     rightbar &
# fi
