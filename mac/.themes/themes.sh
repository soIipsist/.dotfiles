SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
destination_directory="$dotfiles_directory/.config/themes"

rm "$destination_directory"/*.json # removes all existing .json files
theme_path="$SCRIPT_DIR/main.json"

scripts=("$GIT_DOTFILES_DIRECTORY/mac/.vscode/vscode/set_vscode_settings.sh" "")

cp -f "$GIT_DOTFILES_DIRECTORY/mac/set_theme.sh" "$destination_directory/set_theme.sh"
chmod +x "$destination_directory/set_theme.sh"
