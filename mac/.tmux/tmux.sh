install_tmux() {
    if command -v tmux &>/dev/null; then
        return 0
    fi

    echo "tmux not found. Installing..."
    brew install tmux

    if ! command -v tmux &>/dev/null; then
        echo "Failed to install tmux."
        return 1
    fi

    echo "tmux installed successfully."
}

install_tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# replace environment variables and copy
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
themes_path="$dotfiles_directory/.config/themes/theme.sh"

source "$themes_path"
source "$SCRIPT_DIR/tmux/set_tmux_env.sh"
set_tmux_env
