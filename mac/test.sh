#!/bin/bash
source "../json.sh"
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"

variable="\$GIT_EMAIL"
arr_variable="\$SOME_ARRAY"

val=$(get_env_variable $variable)
echo $val

val2=$(get_env_variable $arr_variable)
# echo $val2

for item in $val2; do
    echo $item
done
