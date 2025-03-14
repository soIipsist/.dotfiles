if [ -z "$dotfiles_directory" ]; then
    export dotfiles_directory="$HOME"
fi
if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
    GIT_DOTFILES_DIRECTORY="$HOME/repos/soIipsist/.dotfiles"
fi

# kill processes before restarting
pkill bottombar
pkill leftbar
pkill rightbar
source "$GIT_DOTFILES_DIRECTORY/mac/set_theme.sh" "$1"

launchctl stop homebrew.mxcl.borders
launchctl start homebrew.mxcl.borders
