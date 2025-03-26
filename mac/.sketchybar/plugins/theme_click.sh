# kill processes before restarting
source "$GIT_DOTFILES_DIRECTORY/mac/set_theme.sh"
source "$dotfiles_directory/.config/themes/theme.sh"
set_theme "$1"
launchctl stop homebrew.mxcl.borders
launchctl start homebrew.mxcl.borders
