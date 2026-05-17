uninstall_tmux() {
    if ! command -v tmux &>/dev/null; then
        echo "tmux is not installed."
        return 0
    fi

    brew uninstall tmux
    echo "tmux uninstalled."
}

uninstall_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "oh-my-zsh is not installed."
        return 0
    fi

    rm -rf "$HOME/.oh-my-zsh"
    rm -f "$HOME/.zshrc.pre-oh-my-zsh"

    echo "oh-my-zsh removed."
    echo "You may want to manually clean ~/.zshrc"
}

uninstall_brew() {
    if [ ! -d "/opt/homebrew" ] && [ ! -d "/usr/local/Homebrew" ]; then
        echo "Homebrew is not installed."
        return 0
    fi

    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh | bash

    sudo rm -rf /opt/homebrew
    sudo rm -rf /usr/local/Homebrew

    hash -r

    echo "Homebrew uninstalled."
}


cleanup() {
    local default_path="/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"

    rm -f "$HOME/.zshrc"
    printf 'export PATH="%s"\n' "$default_path" > "$HOME/.zshrc"

    export PATH="$default_path"

    hash -r 2>/dev/null
    rehash 2>/dev/null

    echo "PATH reset:"
    echo "$PATH"
}


uninstall_everything() {
    uninstall_tmux
    uninstall_oh_my_zsh
    uninstall_brew
    cleanup
    echo "Cleanup complete."
}

uninstall_everything
