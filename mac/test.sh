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
download() {
    args="$1"

    SCRIPT_PATH="$SCRIPTS_DIRECTORY/downloader.py"
    cmd="python3 \"$SCRIPT_PATH\" \"$args\""
    echo $cmd
}

while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        echo "$(date): Running download on: $line $DOWNLOADS_FILENAME" >>"$LOG_FILE"
        download "$line"
    fi
done <<<"$NEW_LINES"
