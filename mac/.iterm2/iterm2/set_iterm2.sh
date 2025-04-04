function set_autosuggest_color() {
    if [ -z "$ITERM2_AUTOSUGGEST_COLOR" ]; then
        return 0
    fi

    shell_path="$dotfiles_directory/.zshrc"
    var_name="ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"
    new_value="fg=$ITERM2_AUTOSUGGEST_COLOR"
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    SCRIPT_DIR="$(dirname $SCRIPT_DIR)"

    set_shell_variable "$var_name" "$new_value" "$shell_path"
}

function set_iterm2_theme() {
    if [ -n "$1" ]; then
        source "$1/venv/bin/activate"
    fi
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    python3 "$SCRIPT_DIR/set_theme.py" >/tmp/debug.txt 2>&1
}
