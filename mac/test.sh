# #!/bin/bash
source "../os.sh"
source "../dotfiles.sh"
# source "../git.sh"
source "../json.sh"

# GET JSON VALUE TEST
# some_var=$(get_json_value "some_var" "" "")
# echo $some_var

# VENV PATH TEST
# venv_path=$(get_json_value "venv_path")
# pip_packages=$(get_json_value "pip_packages")
# set_venv_path "$venv_path"
# install_pip_packages "$venv_path" "${pip_packages[@]}"

# GET SHELL VARIABLE TEST
# shell_path=$(get_default_shell_path)
# variable=$(get_shell_variable "SOMEVAR" "$shell_path")
# echo "$variable"

# SET SHELL VARIABLE TEST
# var_name="V2"
# new_value="B"
# shell_path=$(get_default_shell_path)
# shell_path="$HOME/test.sh"
# set_shell_variable "$var_name" "$new_value" "$shell_path"

# SET GIT_DOTFILES_DIRECTORY TEST
# SCRIPT_DIR="$(dirname $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd))"
# set_default_shell_variable "GIT_DOTFILES_DIRECTORY" "$SCRIPT_DIR"
# set_default_shell_variable "SCRIPTS_DIR" "$SCRIPT_DIR/scripts"
SCRIPTS_DIRECTORY="$HOME/repos"
# download() {
#     args="$1"

#     SCRIPT_PATH="$SCRIPTS_DIRECTORY/downloader.py"
#     cmd="python3 \"$SCRIPT_PATH\" \"$args\""
#     echo $cmd
# }

# while IFS= read -r line; do
#     if [[ -n "$line" ]]; then
#         echo "$(date): Running download on: $line $DOWNLOADS_FILENAME" >>"$LOG_FILE"
#         download "$line"
#     fi
# done <<<"$NEW_LINES"

function rsync_pull() {
    # rsync_pull <remote_paths>
    # rsync_pull <remote_paths> [server_alias]
    # rsync_pull <remote_paths> [local_path]
    # rsync_pull <remote_paths> [local_path] [server_alias]

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

    echo "REMOTE: ${remote_paths[@]}"
    echo "LOCAL: $local_dir"
    echo "SERVER: $server_alias"
    # rsync -avz --progress "${remote_paths[@]}" "$local_dir"

}

function rsync_push() {

    # rsync_push <local_paths>
    # rsync_push <local_paths> [server_alias]
    # rsync_push <local_paths> [remote_path] [server_alias]
    # rsync_push <local_paths> [remote_path]

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

# rsync_push file1.txt
# rsync_push mac.sh test.sh wallpaper.sh .zsh/ ~/server
# rsync_push mac.sh test.sh wallpaper.sh .zsh/ ~/file3.txt ~/server server
# rsync_push file1.txt file2.txt file3.txt /server server
# rsync_push ./file1.txt ~/remote_dir # Uses $RSYNC_SERVER
# rsync_push ~/file.txt .some_file ~/some

# rsync_pull ~/file1.txt ~/file2.txt server
# rsync_pull '~/file' ~/file3.sh ~/.zsh/ ~/Desktop server2
rsync_pull '~/Desktop' ~/red ~/file2.sh ~/Desktop
