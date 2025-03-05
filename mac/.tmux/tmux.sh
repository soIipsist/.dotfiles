set_tmux_theme() {
    tmux_config_path="$GIT_DOTFILES_DIRECTORY/mac/.tmux/.tmux.conf"
    tmux_destination_path="$HOME/.tmux/.tmux.conf"

    if [ -f "$tmux_config_path" ]; then
        envsubst <"$tmux_config_path" >"$tmux_destination_path"
    fi

}
