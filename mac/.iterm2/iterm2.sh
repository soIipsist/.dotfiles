destination_directory="$dotfiles_directory/.config/iterm2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/scripts/generate_plist.sh"
source "$SCRIPT_DIR/scripts/set_theme.sh $destination_directory"
