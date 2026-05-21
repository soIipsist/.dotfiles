install_vlc(){
    if [[ -e /Applications/VLC.app ]]; then
        return
    fi
    brew install --cask vlc
}

install_vlc
destination_directory="$dotfiles_directory/Library/Preferences/org.videolan.vlc/"
