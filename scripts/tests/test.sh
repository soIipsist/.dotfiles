# SCRIPTS_DIRECTORY="$HOME/repos"
# DOWNLOADS_FILENAME="downloads.txt"

# download() {
#     args=("$@")

#     for i in "${!args[@]}"; do
#         args[$i]="${args[$i]//\"/\\\"}"
#     done

#     SCRIPT_PATH="$SCRIPTS_DIRECTORY/downloader.py"
#     cmd="python3 \"$SCRIPT_PATH\" \"$args\""
#     echo $cmd
# }

# while IFS= read -r line; do
#     if [[ -n "$line" ]]; then
#         download "$line"
#     fi
# done <"$DOWNLOADS_FILENAME"

rsync_pull_all() {
    args=("$@")
    length=${#args[@]}

    index=0
    last_arg=""
    second_last_arg=""

    server_alias="$RSYNC_SERVER"
    local_dir="."
    remote_paths=()

    usage_msg="Usage: rsync_pull_all <remote_path> [lremote_path_1 ...] [local_dir] [server_alias:$RSYNC_SERVER]"

    if (($# < 1)); then
        echo "$usage_msg"
        return 1
    fi

    for arg in "${args[@]}"; do
        idx_length=$((length - 1))

        is_path=0
        is_remote=1

        # check if arg is a path
        if [[ "$arg" == /* || "$arg" == ./* || "$arg" == ../* || "$arg" == "~/"* || -d "$arg" || "$arg" == "~" ]]; then
            is_path=1
        fi

        if [ "$index" -eq $((idx_length - 1)) ]; then
            second_last_arg="$arg"

            if [ -n "$second_last_arg" ]; then
                if [[ "$is_path" -eq 1 ]]; then

                    if [ -e "$arg" ]; then # is local dir
                        local_dir="$second_last_arg"
                    else # add to remote paths
                        remote_paths+=("$second_last_arg")
                    fi
                else
                    echo "Error: invalid paths provided."
                    return 1
                fi
            fi
        elif [ "$index" -eq "$idx_length" ]; then
            last_arg="$arg"

            # check if last arg is a path or a server alias

            if [ -n "$last_arg" ]; then
                if [[ "$is_path" -eq 1 ]]; then

                    if [ -e "$arg" ]; then # is local dir
                        local_dir="$last_arg"
                    else # add to remote paths
                        remote_paths+=("$last_arg")
                    fi
                else
                    server_alias="$last_arg"
                fi
            fi

        else
            remote_paths+=("$arg")
        fi

        ((index++))
    done

    if [[ -z "$server_alias" ]]; then
        echo "Error: server alias not provided and RSYNC_SERVER is not set."
        return 1
    fi

    if [ ${#remote_paths[@]} -eq 0 ]; then
        echo "Error: no remote paths provided."
        return 1
    fi

    rsync_paths=()
    for path in "${remote_paths[@]}"; do
        rsync_paths+=("${server_alias}:${path}")
    done

    # echo "SERVER" $server_alias
    # echo "LOCAL" $local_dir
    # echo "REMOTE" "${rsync_paths[@]}"

    rsync -avz --progress "${remote_paths[@]}" "$local_dir"
}

# rsync_pull_all "/file.txt" # 1 arg
# rsync_pull_all "/file.txt" "/file2.txt" server yolo # raises an error
# rsync_pull_all server

# rsync_pull_all "~/file.txt" "~/file3.txt" "~/file4.txt" ~/Desktop
rsync_pull_all "test.sh" "~/file3.txt" "~/file4.txt" '~/Desktop' '~/Desktop' serve
# rsync_pull_all

# rsync_pull_all "/file.txt" "nsna" nsnaa "goodbye" "hello" "fafa" "worlgagado"

# rsync_pull_all <remote_paths>
# rsync_pull_all <remote_paths> [server_alias]
# rsync_pull_all <remote_paths> [local_path]
# rsync_pull_all <remote_paths> [local_path] [server_alias]
