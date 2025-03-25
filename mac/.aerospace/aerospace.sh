SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$dotfiles_directory/.config/themes/theme.sh"
source "$SCRIPT_DIR/aerospace/set_aerospace_env.sh"
set_aerospace_env

cp -f "$SCRIPT_DIR/aerospace/set_aerospace_env.sh" "$dotfiles_directory/.config/themes/aerospace"
chmod +x "$dotfiles_directory/.config/themes/aerospace/set_aerospace_env.sh"

cp -f "$SCRIPT_DIR/aerospace/.aerospace.toml" "$dotfiles_directory/.config/themes/aerospace"
