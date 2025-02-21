if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

destination_directory="$dotfiles_directory/.config/colors"
mkdir -p "$destination_directory"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

scripts=("generate_plist.sh")

for script in "${scripts[@]}"; do
    cp -f "$SCRIPT_DIR/scripts/$script" "$destination_directory/$script"
    chmod +x "$destination_directory/$script"
done

source "$SCRIPT_DIR/scripts/generate_plist.sh"

defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$destination_directory"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
