if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

mkdir -p "$dotfiles_directory/.config/iterm2/theme"
destination_directory="$dotfiles_directory/.config/iterm2/theme"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

scripts=("generate_plist.sh")

for script in "${scripts[@]}"; do
    cp -f "$SCRIPT_DIR/scripts/$script" "$destination_directory/$script"
    chmod +x "$destination_directory/$script"
done

# source "$destination_directory/generate_plist.sh" "$SCRIPT_DIR"

defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$destination_directory"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
