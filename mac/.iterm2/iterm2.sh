SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/iterm2/generate_plist.sh" # generate plist in colors directory

defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$SCRIPT_DIR"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2.plist EnableAPIServer -bool true
defaults write com.googlecode.iterm2.plist SUEnableAutomaticChecks -bool true

# killall iTerm2 && open -a iTerm

destination_directory="$SCRIPT_DIR"

# diff <(sed 's/;$/,/; s/ = /=/' iterm.txt) <(sed 's/;$/,/; s/ = /=/' iterm2.txt)
