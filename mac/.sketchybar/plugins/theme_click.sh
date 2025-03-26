# kill processes before restarting
source "$GIT_DOTFILES_DIRECTORY/mac/set_theme.sh"
pkill bottombar
pkill leftbar
pkill rightbar
set_theme "$1"
launchctl stop homebrew.mxcl.borders
launchctl start homebrew.mxcl.borders
