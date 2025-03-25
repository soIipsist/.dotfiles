SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$dotfiles_directory/.config/themes/theme.sh"
source "$SCRIPT_DIR/aerospace/set_aerospace.sh"
set_aerospace_env
