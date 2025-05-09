SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$SCRIPT_DIR"
# defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
# defaults write com.googlecode.iterm2.plist EnableAPIServer -bool true
# defaults write com.googlecode.iterm2.plist SUEnableAutomaticChecks -bool true

# diff <(sed 's/;$/,/; s/ = /=/' iterm.txt) <(sed 's/;$/,/; s/ = /=/' iterm2.txt)

source "$dotfiles_directory/.config/themes/theme.sh"
# activate venv
source "$GIT_DOTFILES_DIRECTORY/venv/bin/activate"
python "$SCRIPT_DIR/iterm2/set_theme.py"
