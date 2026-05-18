install_aerospace(){
    if command -v aerospace &>/dev/null; then
        return 0
    fi

    brew install --cask nikitabobko/tap/aerospace

    echo "Successfully installed aerospace."
}

install_aerospace
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$dotfiles_directory/.config/themes/theme.sh"
source "$SCRIPT_DIR/aerospace/set_aerospace.sh"
set_aerospace_env
