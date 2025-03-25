SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
destination_directory="$dotfiles_directory/.config/themes"

rm "$destination_directory"/*.json # removes all existing .json files
theme_path="$SCRIPT_DIR/main.json"
