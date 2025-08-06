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

rsync_push_all() {

    # rsync_push_all <local_paths>
    # rsync_push_all <local_paths> [server_alias]
    # rsync_push_all <local_paths> [remote_path] [server_alias]
    # rsync_push_all <local_paths> [remote_path]

    if (($# < 1)); then
        echo "Usage: rsync_push <local_path1> [local_path2 ...] <remote_dir> [server_alias:$RSYNC_SERVER]"
        return 1
    fi

    local server_alias="$RSYNC_SERVER"
    local remote_dir="."
    local local_paths=()

    if (($# == 1)); then
        local_paths=("$1")
    else

        local last_arg="${@: -1}"
        local second_last="${@: -2:1}"

        if [ -e "$last_arg" ]; then # this exists, so it's not remote
            local_paths+=($last_arg)
            local_paths+=($second_last)

        else # this is remote or server alias
            if [[ "$last_arg" == /* || "$last_arg" == ./* || "$last_arg" == ../* || "$last_arg" == "~/"* || -d "$last_arg" || "$last_arg" == "~" ]]; then
                remote_dir="$last_arg"
            else
                server_alias="$last_arg"
            fi
        fi

        if [ -e "$second_last" ]; then # this exists, so it's not remote
            local_paths+=("$second_last")
        else
            remote_dir="$second_last"
        fi

        set -- "${@:1:$(($# - 2))}"

        local_paths+=("$@")

    fi

    if [[ -z "$server_alias" ]]; then
        echo "Error: server alias not provided and RSYNC_SERVER is not set."
        return 1
    fi

    if [ -z "$local_paths" ]; then
        echo "Error: no valid local paths provided."
        return 1
    fi

    # echo "LOCAL PATHS: ${local_paths[@]}"
    # echo "REMOTE: $remote_dir"
    # echo "SERVER: $server_alias"

    rsync -avz --progress "${local_paths[@]}" "${server_alias}:${remote_dir}"
}

rsync_pull_all() {
    # rsync_pull_all <remote_paths>
    # rsync_pull_all <remote_paths> [server_alias]
    # rsync_pull_all <remote_paths> [local_path]
    # rsync_pull_all <remote_paths> [local_path] [server_alias]

    if (($# < 1)); then
        echo "Usage: rsync_pull <remote_path1> [remote_path2 ...] [local_dir] [server_alias:$RSYNC_SERVER]"
        return 1
    fi

    local server_alias="$RSYNC_SERVER"
    local local_dir="."
    local remote_paths=()

    if (($# == 1)); then
        remote_paths=("$1")
    else
        local last_arg="${@: -1}"
        local second_last="${@: -2:1}"

        echo $last_arg $second_last

        # is remote path or local path
        if [[ "$last_arg" == /* || "$last_arg" == ./* || "$last_arg" == ../* || "$last_arg" == "~/"* || -d "$last_arg" ]]; then

            if [ -e "$last_arg" ]; then # this is local
                local_dir="$last_arg"
                remote_paths+=("$second_last")

            else # add all remaining args as remote paths
                remote_paths+=("$last_arg")
                remote_paths+=("$second_last")
            fi
        else
            # is server alias
            server_alias="$last_arg"

            if [ -e "$second_last" ]; then # this is local
                local_dir="$second_last"
            else # add all remaining args as remote paths
                remote_paths+=("$second_last")
            fi
        fi

        set -- "${@:1:$(($# - 2))}"

        remote_paths+=("$@")
    fi

    if [[ -z "$server_alias" ]]; then
        echo "Error: server alias not provided and RSYNC_SERVER is not set."
        return 1
    fi

    if [ -z "$remote_paths" ]; then
        echo "Error: no valid remote paths provided."
        return 1
    fi

    # echo "REMOTE: ${remote_paths[@]}"
    # echo "LOCAL: $local_dir"
    # echo "SERVER: $server_alias"
    for i in "${!remote_paths[@]}"; do
        remote_paths[$i]="${server_alias}:${remote_paths[$i]}"
    done

    rsync -avz --progress "${remote_paths[@]}" "$local_dir"

}

# venv scripts
sqliteq() {
    run_venv_script "sqlite.py" "$@"
}

organize_files() {
    run_venv_script "organize_files.py" "$@"
}
