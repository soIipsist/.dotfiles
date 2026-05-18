install_fzf(){
    if command -v fzf &>/dev/null; then
        return 0
    fi

    brew install fzf

}

install_fzf