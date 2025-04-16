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
# set_venv_flag=$(get_json_value "set_venv_path")
# pip_packages=$(get_json_value "pip_packages")
# set_venv_path "$venv_path" "$set_venv_flag"
# install_pip_packages "$venv_path" "${pip_packages[@]}"

# GET SHELL VARIABLE TEST
shell_path=$(get_default_shell_path)
ytdlp=$(get_shell_variable "SOMEVAR" "$shell_path")
echo "$ytdlp"

# SET SHELL VARIABLE TEST
# var_name="V2"
# new_value="B"
# shell_path=$(get_default_shell_path)
# shell_path="$HOME/test.sh"
# set_shell_variable "$var_name" "$new_value" "$shell_path"
