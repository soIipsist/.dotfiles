install_borders(){
    if command -v borders &>/dev/null; then
        return
    fi
    brew tap FelixKratz/formulae
    brew install borders
}

install_borders
destination_directory="$dotfiles_directory/.config/borders"
