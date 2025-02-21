PrefsFolder="$1"

if [ -z "$1" ]; then
    PrefsFolder="$PWD"
fi

defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$PrefsFolder"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

# set fonts

killall iTerm2
