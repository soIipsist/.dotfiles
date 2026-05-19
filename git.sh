source "../json.sh"

git_config() {
  git_username="$1"
  git_email="$2"

  if [ ! -z $git_username ]; then
    echo "Default git username was set to: $git_username"
    git config --global user.name $git_username
  fi

  if [ ! -z $git_email ]; then
    echo "Default git email was set to: $git_email"
    git config --global user.email $git_email
  fi
}

clone_git_repos() {
  git_repos="$1"
  git_home="$2"

  if [ -z "$git_repos" ]; then
    return
  fi

  if [ -z "$git_home" ]; then
    git_home="$HOME"
  fi

  mkdir -p "$git_home" || return 1
  cd "$git_home" || return 1

  for repo in $git_repos; do
    git clone "$repo"
  done
}
