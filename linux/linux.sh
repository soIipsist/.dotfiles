#!/bin/bash
source "../json.sh"
source "../dotfiles.sh"
source "../git.sh"

set_lockscreen_and_wallpaper() {
    wallpaper_path="$1"
    lockscreen_path="$2"
    desktop_environment="$XDG_CURRENT_DESKTOP"

    echo "Current desktop environment: $desktop_environment"

    case "$desktop_environment" in
    "GNOME")
        lockscreen_command="gsettings set org.gnome.desktop.screensaver picture-uri '$lockscreen_path'"
        wallpaper_command="gsettings set org.gnome.desktop.background picture-uri '$wallpaper_path'"
        ;;
    "KDE")
        lockscreen_command="kwriteconfig5 --file kscreenlockerrc --group Greeter --key WallpaperFile '$lockscreen_path'"
        wallpaper_command="kwriteconfig5 --file kwinrc --group Wallpaper --key Image '$wallpaper_path'"
        ;;
    "Xfce")
        lockscreen_command="xfconf-query -c xfce4-desktop -p /backdrop/screen0/lockscreen/last-image -s '$lockscreen_path'"
        wallpaper_command="xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s '$wallpaper_path'"
        ;;
    "X-Cinnamon")
        wallpaper_command="gsettings set org.cinnamon.desktop.background picture-uri '$wallpaper_path'"
        ;;
    *)
        echo "Unknown desktop environment: $desktop_environment."
        ;;
    esac

    # Execute lockscreen command if not empty
    if [ -n "$lockscreen_path" ]; then
        eval "$lockscreen_command"
    fi

    # Execute wallpaper command if not empty
    if [ -n "$wallpaper_path" ]; then
        eval "$wallpaper_command"
    fi
}

hostname=$(get_json_value "hostname")
apt_packages=$(get_json_value "apt_packages")
dotfiles=$(get_json_value "dotfiles")
git_username=$(get_json_value "git_username")
git_email=$(get_json_value "git_email")
git_home_path=$(get_json_value "git_home_path")
git_repos=$(get_json_value "git_repos")
wallpaper_path=$(get_json_value "wallpaper_path")
lockscreen_path=$(get_json_value "lockscreen_path")

echo $apt_packages

for package in $apt_packages; do
    sudo apt install --yes --no-install-recommends "$package"
done

git_config $git_username $git_email
clone_git_repos "${git_repos[@]}" $git_home_path
set_lockscreen_and_wallpaper "$wallpaper_path" "$lockscreen_path"

dotfile_folders=$(get_dotfile_folders "${dotfiles[@]}")
install_dotfiles "${dotfile_folders[@]}" $HOME
