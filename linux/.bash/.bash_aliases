alias python='python3'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ps='ps aux --sort=-%mem | head'

mnt_vfat() {
    if [ $# -ne 2 ]; then
        echo "Usage: mnt_vfat <device> <mount_point>"
        return 1
    fi

    if [ ! -d "$2" ]; then
        sudo mkdir -p "$2"
    fi
    sudo mount -o uid=$(id -u),gid=$(id -g) "$1" "$2"
}

mnt_exfat() {
    if [ $# -ne 2 ]; then
        echo "Usage: mnt_exfat <device> <mount_point>"
        return 1
    fi

    if [ ! -d "$2" ]; then
        sudo mkdir -p "$2"
    fi

    sudo mount -t exfat -o uid=$(id -u),gid=$(id -g) "$1" "$2"
}

mnt_ntfs() {
    if [ $# -ne 2 ]; then
        echo "Usage: mnt_exfat <device> <mount_point>"
        return 1
    fi

    if [ ! -d "$2" ]; then
        sudo mkdir -p "$2"
    fi

    sudo mount -t ntfs-3g -o uid=$(id -u),gid=$(id -g) "$1" "$2"
}

mnt_auto() {
    if [ $# -ne 2 ]; then
        echo "Usage: mnt_auto <device> <mount_point>"
        return 1
    fi

    device="$1"
    mount_point="$2"

    if [ ! -d "$mount_point" ]; then
        sudo mkdir -p "$mount_point"
    fi

    fstype=$(lsblk -no FSTYPE "$device")

    case "$fstype" in
    vfat)
        mnt_vfat "$device" "$mount_point"
        ;;
    exfat)
        mnt_exfat "$device" "$mount_point"
        ;;
    ntfs)
        mnt_ntfs "$device" "$mount_point"
        ;;
    *)
        echo "Unsupported or unknown filesystem: $fstype"
        return 2
        ;;
    esac
}

ytdlp_mp4() {

    if [ -z "$SCRIPTS_DIRECTORY" ]; then
        SCRIPTS_DIRECTORY="$HOME/scripts"
    fi

    if [ -n "$VENV_PATH" ]; then
        source $VENV_PATH/bin/activate
    fi

    if [ ! -e "$YTDLP_PATH" ]; then
        curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o "$YTDLP_PATH"
        chmod a+rx "$YTDLP_PATH"
    fi

    python3 $SCRIPTS_DIRECTORY/ytdlp.py -f video -v mp4 "$@"

    # Deactivate the virtual environment properly
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
    fi
}

ytdlp_mp3() {

    if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
        echo "Could not find GIT_DOTFILES_DIRECTORY."
        return
    fi

    if [ -n "$VENV_PATH" ]; then
        source $VENV_PATH/bin/activate
    fi

    if [ ! -e "$YTDLP_PATH" ]; then
        curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o "$YTDLP_PATH"
        chmod a+rx "$YTDLP_PATH"
    fi

    python3 $GIT_DOTFILES_DIRECTORY/scripts/ytdlp.py -f audio -a mp3 "$@"
    # Deactivate the virtual environment properly
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
    fi
}
