set_tmux_env() {
    # replace environment variables and copy
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    source_tmux_conf="$SCRIPT_DIR/.tmux.conf"
    destination_tmux_conf="$dotfiles_directory/.tmux.conf"
    envsubst <"$source_tmux_conf" >"$destination_tmux_conf"
    echo "Copied $source_tmux_conf to $destination_tmux_conf."
}
