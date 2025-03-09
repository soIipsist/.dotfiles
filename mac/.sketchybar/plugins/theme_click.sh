if [ -z "$dotfiles_directory" ]; then
    export dotfiles_directory="$HOME"
fi
if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
    GIT_DOTFILES_DIRECTORY="$HOME/repos/soIipsist/.dotfiles"
fi

echo "THEME CLICKED $1" >>/tmp/debug.txt
source "$GIT_DOTFILES_DIRECTORY/mac/set_theme.sh" "$1"
# source "$GIT_DOTFILES_DIRECTORY/mac/.sketchybar/reload.sh"
