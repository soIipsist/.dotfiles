#!/bin/bash
source "../json.sh"
source "../dotfiles.sh"
source "../git.sh"
source "../os.sh"

set_lockscreen_and_wallpaper() {
    wallpaper_path="$1"
    lockscreen_path="$2"
    desktop_environment="$XDG_CURRENT_DESKTOP"

    if [ -n "$desktop_environment" ]; then
        echo "Current desktop environment: $desktop_environment"
    fi

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

install_zoxide() {
    if [ -z "$1" ] || [ "$1" == false ]; then
        return
    fi

    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

    if ! grep -q 'eval "$(zoxide init bash)"' "$shell_path"; then
        echo 'eval "$(zoxide init bash)"' >>"$shell_path"
    fi

}

hostname=$(get_json_value "hostname")
apt_packages=$(get_json_value "apt_packages")
dotfiles=$(get_json_value "dotfiles")
dotfiles_directory=$(get_json_value "dotfiles_directory" "" "$HOME") # will be $HOME by default
scripts=$(get_json_value "scripts")
excluded_scripts=$(get_json_value "excluded_scripts")
git_username=$(get_json_value "git_username")
git_email=$(get_json_value "git_email")
git_home=$(get_json_value "git_home")
git_repos=$(get_json_value "git_repos")
wallpaper_path=$(get_json_value "wallpaper_path")
lockscreen_path=$(get_json_value "lockscreen_path")
install_homebrew_flag=$(get_json_value "install_homebrew")
install_zoxide_flag=$(get_json_value "install_zoxide")
brew_packages=$(get_json_value "brew_packages")
brew_cask_packages=$(get_json_value "brew_cask_packages")

install_homebrew "$install_homebrew_flag"
install_zoxide "$install_zoxide_flag"
install_brew_packages "$brew_packages" "$brew_cask_packages"

apt_packages_array=($apt_packages)
sudo apt install --yes --no-install-recommends "${apt_packages_array[@]}"

install_dotfiles "$dotfiles_directory" "$dotfiles" "$scripts" "$excluded_scripts"
git_config "$git_username" "$git_email"
clone_git_repos "${git_repos[@]}" "$git_home"
set_lockscreen_and_wallpaper "$wallpaper_path" "$lockscreen_path"
