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
