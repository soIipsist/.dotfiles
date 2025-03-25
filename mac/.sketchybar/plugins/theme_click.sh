# kill processes before restarting
pkill bottombar
pkill leftbar
pkill rightbar
source "$dotfiles_directory/.config/themes/set_theme.sh" "$1"

launchctl stop homebrew.mxcl.borders
launchctl start homebrew.mxcl.borders
