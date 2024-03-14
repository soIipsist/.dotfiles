source "../json.sh"
source "../dotfiles.sh"

git_config() {
    git_username=$(get_json_value "git_username")
    git_email=$(get_json_value "git_email")

    if [ ! -z $git_username ]; then
        echo "Default git username was set to: $git_username"
        git config --global user.name $git_username
    fi

    if [ ! -z $git_email ]; then
        echo "Default git email was set to: $git_email"
        git config --global user.email $git_email
    fi
}

dir="$PWD/.git-config"
dotfiles=$(get_dotfiles $dir)
destination_directory="$HOME"
# sudo -s 
git_config
move_dotfiles "${dotfiles[@]}" "${destination_directory}"