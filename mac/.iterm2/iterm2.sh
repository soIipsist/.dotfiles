if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

destination_directory="$dotfiles_directory/.config/colors"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
scripts=("generate_plist.sh" "set_preset.py")

for script in "${scripts[@]}"; do
    cp -f "$SCRIPT_DIR/scripts/$script" "$destination_directory/$script"
    chmod +x "$destination_directory/$script"
done

source "$SCRIPT_DIR/scripts/generate_plist.sh" # generate plist in colors directory

defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$destination_directory"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2.plist EnableAPIServer -bool true

killall iTerm2 && open -a iTerm
python "$destination_directory/set_preset.py"
