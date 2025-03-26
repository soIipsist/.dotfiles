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
