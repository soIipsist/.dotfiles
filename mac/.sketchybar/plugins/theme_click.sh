# kill processes before restarting
pkill bottombar
pkill leftbar
pkill rightbar
source "$GIT_DOTFILES_DIRECTORY/mac/set_theme.sh" "$1"

launchctl stop homebrew.mxcl.borders
launchctl start homebrew.mxcl.borders
