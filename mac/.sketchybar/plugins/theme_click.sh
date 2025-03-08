if [ -z "$dotfiles_directory" ]; then
    export dotfiles_directory="$HOME"
fi
if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
    GIT_DOTFILES_DIRECTORY="$HOME/repos/soIipsist/.dotfiles"
fi

theme="$1"
if [ -z "$theme" ]; then
    theme="main"
fi

source "$GIT_DOTFILES_DIRECTORY/mac/set_theme.sh" "$theme"
# sketchybar -m --set themes.logo popup.drawing=toggle
