_fzf_version_ok() {
    local min="${1:-0.45.0}" current
    command -v fzf &>/dev/null || return 1
    current=$(fzf --version | awk '{print $1}')
    [ "$(printf '%s\n%s\n' "$min" "$current" | sort -V | head -n1)" = "$min" ]
}

install_fzf() {
    local min_version="0.45.0"

    _fzf_version_ok "$min_version" && return 0

    case "$(uname -s)" in
    Darwin)
        if ! command -v brew &>/dev/null; then
            echo "Homebrew is required to install fzf on macOS." >&2
            return 1
        fi
        if brew list fzf &>/dev/null; then
            brew upgrade fzf
        else
            brew install fzf
        fi
        ;;
    Linux)
        if [ -d "$HOME/.fzf/.git" ]; then
            git -C "$HOME/.fzf" pull --ff-only || return 1
        else
            git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" || return 1
        fi
        "$HOME/.fzf/install" --bin || return 1
        mkdir -p "$HOME/.local/bin"
        ln -sf "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"
        ;;
    *)
        echo "Unsupported OS: $(uname -s)" >&2
        return 1
        ;;
    esac

    hash -r 2>/dev/null

    if ! _fzf_version_ok "$min_version"; then
        echo "fzf is still older than $min_version. Run 'type -a fzf' to see which binary is winning on PATH." >&2
        return 1
    fi
}
install_fzf