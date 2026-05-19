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

    echo "Autohide dock enabled."
}

hide_top_bar(){
    if [ -z "$1" ]; then
        return 0
    fi

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    osascript "$SCRIPT_DIR/hide_top_bar.scpt" "$1"
    echo "Top bar visibility set to: $1."
}

set_wallpaper() {

    wallpaper_path="$1"

    if [ -z "$wallpaper_path" ]; then
        return
    fi

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    osascript "$SCRIPT_DIR/wallpaper.scpt" $wallpaper_path
    echo "Set wallpaper to: $wallpaper_path"

}

