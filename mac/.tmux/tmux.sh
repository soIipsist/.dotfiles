# replace environment variables and copy
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
themes_path="$dotfiles_directory/.config/themes/theme.sh"

source "$themes_path"
source "$SCRIPT_DIR/tmux/set_tmux_env.sh"
set_tmux_env

cp -f "$SCRIPT_DIR/tmux/set_tmux_env.sh" "$dotfiles_directory/.config/themes"
chmod +x "$dotfiles_directory/.config/themes/set_tmux_env.sh"

cp -f "$SCRIPT_DIR/tmux/.tmux.conf" "$dotfiles_directory/.config/themes"
