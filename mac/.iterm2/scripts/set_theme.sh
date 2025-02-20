PrefsFolder="$1"

defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$PrefsFolder"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
killall iTerm2
