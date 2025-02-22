#!/bin/bash
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"
source "../json.sh"

get_wallpaper_path() {
    wallpaper_path="$(get_json_value "wallpaper_path")"
    color_scheme="$1"
    dotfiles_directory="$2"

    destination_directory="$dotfiles_directory/.config/colors"
    color_scheme_path="$destination_directory/$color_scheme.json"

    if [[ -f "$color_scheme_path" && -z "$wallpaper_path" ]]; then
        wallpaper_path=$(get_json_value "WALLPAPER_PATH" "$color_scheme_path")
    fi

    echo "$wallpaper_path"

}
dotfiles_directory=$(get_json_value "dotfiles_directory" "" "$HOME") # will be $HOME by default
color_scheme=$(get_json_value "color_scheme")

echo $color_scheme
wallpaper_path=$(get_wallpaper_path "$color_scheme" "$dotfiles_directory")

echo $wallpaper_path
