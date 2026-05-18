install_from_brewfile() {
    brewfile_path="$1"

    if [ -z $brewfile_path ]; then
        return
    fi

    brew bundle --file $brewfile_path
}

clear_dock(){

if [ -z "$1" ] || [ "$1" = "false" ]; then
        return 0
fi

defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock show-recents -bool false
killall Dock

echo "Dock apps removed."

}

clear_dock_others() {
    if [ -z "$1" ] || [ "$1" = "false" ]; then
        return 0
    fi

    defaults write com.apple.dock persistent-others -array
    defaults write com.apple.dock show-recents -bool false
    killall Dock

    echo "Dock right side cleared."
}

autohide_dock(){
    if [ -z "$1" ] || [ "$1" = "false" ]; then
        return 0
    fi
    
    defaults write com.apple.dock autohide -bool true
    killall Dock
}

set_wallpaper() {

    wallpaper_path="$1"

    if [ -z "$wallpaper_path" ]; then
        return
    fi

    if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
        GIT_DOTFILES_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    fi

    osascript "$GIT_DOTFILES_DIRECTORY/mac/wallpaper.scpt" $wallpaper_path
    echo "Set wallpaper to: $wallpaper_path"

}

