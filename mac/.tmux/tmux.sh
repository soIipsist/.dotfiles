SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source_tmux_conf="$SCRIPT_DIR/tmux/.tmux.conf"
destination_tmux_conf="$dotfiles_directory/.tmux.conf"

# replace environment variables and copy
themes_path="$dotfiles_directory/.config/themes/theme.sh"
source "$themes_path"
envsubst <"$source_tmux_conf" >"$destination_tmux_conf"
