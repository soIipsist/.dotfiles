install_from_brewfile() {
    brewfile_path="$1"

    if [ -z $brewfile_path ]; then
        return
    fi

    brew bundle --file $brewfile_path
}

clear_dock(){

if [ -z "$1" ] || [ "$1" = "false" ]; then
        return
fi

defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock show-recents -bool false
killall Dock

echo "Dock apps removed."

}

clear_dock_others() {
    if [ -z "$1" ] || [ "$1" = "false" ]; then
        return
    fi

    defaults write com.apple.dock persistent-others -array
    defaults write com.apple.dock show-recents -bool false
    killall Dock

    echo "Dock right side cleared."
}

autohide_dock(){
    if [ -z "$1" ] || [ "$1" = "false" ]; then
        return
    fi

    defaults write com.apple.dock autohide -bool true
    killall Dock

    echo "Autohide dock enabled."
}

hide_top_bar(){
    if [ -z "$1" ]; then
        return
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

    osascript "$SCRIPT_DIR/wallpaper.scpt" "$wallpaper_path"
    echo "Set wallpaper to: $wallpaper_path"

}

perform_backup() {
    local backup_path="$1"

    if [[ -z "$backup_path" ]]; then
        return
    fi

    echo "Setting Time Machine destination: $backup_path"

    if ! sudo tmutil setdestination "$backup_path"; then
        echo "Failed to set Time Machine destination."
        return
    fi

    if ! tmutil destinationinfo | grep -q "Name"; then
        echo "No valid Time Machine destination detected."
        return
    fi

    echo "Starting Time Machine backup..."
    sudo tmutil startbackup --auto
}

enable_sudo_touch_id() {
    
    if [ -z "$1" ] || [ "$1" = "false" ]; then
        return
    fi

    local file="/etc/pam.d/sudo"
    local line="auth       sufficient     pam_tid.so"
    local backup="/etc/pam.d/sudo.bak"

    echo "Installing tmux compatibility packages..."

    if command -v brew >/dev/null 2>&1; then
        brew install pam-reattach
    else
        echo "Homebrew is not installed."
        echo "Install it from:"
        echo "https://brew.sh"
        return
    fi

    sudo cp "$file" "$backup"
    echo "Backup created at $backup"

    if sudo grep -q "pam_tid.so" "$file"; then
        echo "Touch ID for sudo is already enabled."
        return
    fi

    sudo awk -v line="$line" '
        NR==1 {print line}
        {print}
    ' "$file" | sudo tee "$file" > /dev/null

    echo "Touch ID for sudo enabled."
}


set_time() {
    local input_time="$1"

    if [[ -z "$input_time" ]]; then
        return 1
    fi

    local current_date
    current_date=$(date "+%m%d")

    local current_year
    current_year=$(date "+%Y")

    local formatted
    formatted=$(date -j -f "%H:%M:%S" \
        "$input_time" "+%H%M%Y.%S")

    if [[ -z "$formatted" ]]; then
        echo "Invalid time format"
        return 1
    fi

    echo "Setting system time to: $input_time"
    sudo systemsetup -setusingnetworktime off

    sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.timed.plist
    sudo defaults write /Library/Preferences/com.apple.timezone.auto Active -bool false

    sudo killall timed
    sudo date "${current_date}${formatted}"
}

set_timezone(){

    if [[ -z "$1" ]]; then
        return 1
    fi

    sudo systemsetup -settimezone "$1"
    sudo sntp -sS time.apple.com
}