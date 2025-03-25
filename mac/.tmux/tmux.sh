# replace environment variables and copy
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
themes_path="$dotfiles_directory/.config/themes/theme.sh"

source "$themes_path"
source "$SCRIPT_DIR/tmux/set_tmux_env.sh"
set_tmux_env
