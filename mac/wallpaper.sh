set_wallpaper() {

    wallpaper_path="$1"

    if [ -z "$wallpaper_path" ]; then
        return
    fi

    osascript wallpaper.scpt $wallpaper_path
    echo "Set wallpaper to: $wallpaper_path"

}
