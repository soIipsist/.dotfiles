alias python='python3'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ps='ps aux --sort=-%mem | head'

rsync_push() {
    local file="$1"
    local server_alias="${2:-$RSYNC_REMOTE}"
    local remote_dir="${3:-$RSYNC_REMOTE_DIR}"

    if [[ -z $file || -z $server_alias || -z $remote_dir ]]; then
        echo "Usage: rsync_push <file|dir> [server_alias] [/remote/dir]"
        return 1
    fi

    rsync -avz --progress "$file" "${server_alias}:${remote_dir}/"
}

rsync_pull() {
    local file="$1"
    local server_alias="${2:-$RSYNC_REMOTE}"
    local remote_dir="${3:-$RSYNC_REMOTE_DIR}"
    local local_dir="${4:-.}"

    if [[ -z $file || -z $server_alias || -z $remote_dir ]]; then
        echo "Usage: rsync_pull <file|dir> [server_alias] [/remote/dir] [local_dir]"
        return 1
    fi

    rsync -avz --progress \
        "${server_alias}:${remote_dir}/${file}" \
        "${local_dir}/"
}
