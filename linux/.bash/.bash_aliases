# useful environment variables
export GIT_HOME="$HOME/repos/soIipsist"
export DEFAULT_EDITOR="nano"
export VSCODE_WORKSPACE_DIRECTORY="$GIT_HOME/.workspaces"

# sqlite variables
export SQLITE_DB="$SCRIPTS_DIRECTORY/downloads.db"
export SQLITE_TABLE="downloads"

# set_env variables
export ENV_SKIP_CONFIRM=0
export ENV_DEFAULT_ACTION="set"
export KIWIX_PATH="/mnt/HOME/wikipedia/library.xml"

# organize files variables
export BACKUP_DIRECTORY="/tmp/backup"
export DRY_RUN=0
export MOVE_FILES=0

alias python='python3'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ps='ps aux --sort=-%mem | head'

# tmux aliases
alias t='tmux attach || tmux new-session'
alias ta='tmux attach -t'
alias tn='tmux new-session'
alias tl='tmux list-sessions'
alias tk='tmux kill-server'

# docker aliases
alias dpl="docker pull"
alias dlc="docker container ls"
alias dlca="docker container ls -a"
alias dli="docker images"
alias dsc="docker container stop"
alias drc="docker container rm"
alias dri="docker image rm"

# general service control
alias sstart='sudo systemctl start'
alias sstop='sudo systemctl stop'
alias srestart='sudo systemctl restart'
alias sstatus='systemctl status'
alias senable='sudo systemctl enable'
alias sdisable='sudo systemctl disable'
alias sreload='sudo systemctl reload'
alias sactive='systemctl is-active'
alias senabled='systemctl is-enabled'
alias sfailed='systemctl --failed'
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
    local service_name="$1"

    if [[ -z "$service_name" ]]; then
        echo "Usage: ssrestart <service-name>"
        return 1
    fi

    if [[ ! -f "$service_name" ]]; then
        service_name="$GIT_DOTFILES_DIRECTORY/linux/.services/services/$service_name.conf"
    fi

    if [[ ! -f "$service_name" ]]; then
        echo "Error: Config file not found: $service_name"
        return 1
    fi

    source /usr/local/bin/restart_service "$service_name"
}

# venv scripts
sqliteq() {
    run_venv_script "sqlite.py" "$@"
}

organize_files() {
    if [ "$1" = "--sudo" ]; then
        shift
        run_venv_script --sudo "organize_files.py" "$@"
    else
        run_venv_script "organize_files.py" "$@"
    fi
}

set_env() {
    run_venv_script "set_env.py" "$@"
}

sudoe() {
    if (($# == 0)); then
        echo "Usage: sudoe <command> [args...]"
        return 1
    fi

    local cmd=$1
    shift

    local quoted_args=()
    for arg in "$@"; do
        quoted_args+=("$(printf '%q' "$arg")")
    done
    local joined_args="${quoted_args[*]}"

    if [[ $(type "$cmd") == *function* ]]; then
        if [[ -n $ZSH_VERSION ]]; then
            command sudo -E zsh -ic "source /home/$USER/.zshrc; $cmd $joined_args"
        else
            command sudo -E bash -ic "source /home/$USER/.bashrc; $cmd $joined_args"
        fi
    elif [[ $(type "$cmd") == *alias* ]]; then
        if [[ -n $ZSH_VERSION ]]; then
            command sudo -E zsh -ic "source /home/$USER/.zshrc; $cmd $joined_args"
        else
            command sudo -E bash -ic "source /home/$USER/.bashrc; $cmd $joined_args"
        fi
    else
        command sudo "$cmd" "$@"
    fi
}

kiwix_manage() {
    local lib_file="${1:-$KIWIX_PATH}"

    if [[ -z "$lib_file" ]]; then
        echo "Usage: kiwix_manage <library.xml> [zim files...]"
        return 1
    fi

    if [[ "$lib_file" != *.xml ]]; then
        echo "Error: library file must have a .xml extension"
        return 1
    fi

    local zim_files=()

    if (($# > 1)); then
        shift
        zim_files=("$@")
    else
        local parent_dir
        parent_dir="$(dirname "$lib_file")"
        zim_files=("$parent_dir"/*.zim)
    fi

    for zim in "${zim_files[@]}"; do
        if [[ -f "$zim" ]]; then
            echo "Adding $zim to $lib_file"
            kiwix-manage "$lib_file" add "$zim"
        else
            echo "Warning: $zim not found"
        fi
    done
}
