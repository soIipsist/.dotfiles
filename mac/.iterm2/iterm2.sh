if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

destination_directory="$dotfiles_directory/.config/colors"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# copy generate_plist script
generate_plist_path="$SCRIPT_DIR/scripts/generate_plist.sh"
cp -f "$generate_plist_path" "$destination_directory"
chmod +x "$destination_directory/$script"

source "$SCRIPT_DIR/scripts/generate_plist.sh" # generate plist in colors directory

defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$destination_directory"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
