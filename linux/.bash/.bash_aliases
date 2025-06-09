alias python='python3'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ps='ps aux --sort=-%mem | head'

# general service control
alias sstart='sudo systemctl start'
alias sstop='sudo systemctl stop'
alias srestart='sudo systemctl restart'
alias sstatus='systemctl status'
alias senable='sudo systemctl enable'
alias sdisable='sudo systemctl disable'
alias sjournal='journalctl -u'
alias sjtail='journalctl -fu'

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

sedit() {
    local service="$1"
    local conf="/etc/default/${service}.conf"

    if [[ -z "$service" ]]; then
        echo "Usage: sedit <service-name>"
        return 1
    fi

    if [[ -f "$conf" ]]; then
        sudo "${EDITOR:-nano}" "$conf"
    else
        sudo systemctl edit "$service"
    fi
}

ssrestart() {
    local service="$1"

    if [[ -z "$service" ]]; then
        echo "Usage: ssrestart <service-name>"
        return 1
    fi

    if [[ ! -f "$service" ]]; then
        service="$GIT_DOTFILES_DIRECTORY/linux/.services/services/$service.conf"
    fi

    if [[ ! -f "$service" ]]; then
        echo "Error: Config file not found: $service"
        return 1
    fi

    source /usr/local/bin/restart_service "$service"
}

get_codec() {
    if [ ! -f "$1" ]; then
        echo "File not found: $1" >&2
        return 1
    fi
    codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$1")
    echo "$codec"
}
