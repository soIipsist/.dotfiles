# useful environment variables
export GIT_HOME="$HOME/repos/soIipsist"
# export RSYNC_PATH=""
export RSYNC_SERVER="home"

# sqlite variables
export SQLITE_DB="downloads.db"
export SQLITE_TABLE="downloads"

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

git_pull_all() {
    local base_dir="${GIT_HOME:-.}"

    echo "Running git pull in each subdirectory of: $base_dir"

    find "$base_dir" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
        if [ -d "$dir/.git" ]; then
            echo ">>> Pulling in $dir"
            git -C "$dir" pull
        else
            echo "Skipping $dir — not a git repository."
        fi
    done
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

rsync_push() {
    local local_path="$1"
    local remote_path="${2:-$RSYNC_PATH}"
    local server_alias="${3:-$RSYNC_SERVER}"

    if [[ -z "$local_path" || -z "$server_alias" ]]; then
        echo "Usage: rsync_push <local_path> [remote_path] [server_alias]"
        return 1
    fi

    if [ -z "$remote_path" ]; then
        remote_path="."
    fi

    rsync -avz --progress "$local_path" "${server_alias}:${remote_path}"
}

rsync_pull() {
    local remote_path="$1"
    local local_path="${2:-$RSYNC_PATH}"
    local server_alias="${3:-$RSYNC_SERVER}"

    if [[ -z "$remote_path" || -z "$server_alias" ]]; then
        echo "Usage: rsync_pull <remote_path> [local_path] [server_alias]"
        return 1
    fi

    if [ -z "$local_path" ]; then
        local_path="."
    fi

    rsync -avz --progress \
        "${server_alias}:${remote_path}" \
        "${local_path}"
}

# venv scripts
sqliteq() {
    run_venv_script "sqlite.py" "$@"
}

organize_files() {
    run_venv_script "organize_files.py" "$@"
}
