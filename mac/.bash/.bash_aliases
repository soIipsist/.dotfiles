alias python='python3'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ps='ps aux --sort=-%mem | head'

# sqlite variables
export SQLITE_DB="downloads.db"
export SQLITE_TABLE="downloads"

# export RSYNC_PATH=""
export RSYNC_SERVER="home"

sqliteq() {
    run_venv_script "sqlite.py" "$@"
}

rsync_push() {
    local local_path="$1"
    local remote_path="${2:-$RSYNC_PATH}"
    local server_alias="${3:-$RSYNC_SERVER}"

    if [[ -z "$local_path" || -z "$server_alias" ]]; then
        echo "Usage: rsync_push <remote_path> [local_path] [server_alias]"
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
