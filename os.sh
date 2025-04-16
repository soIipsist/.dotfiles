get_os() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
  Linux*) machine=linux ;;
  Darwin*) machine=mac ;;
  CYGWIN*) machine=windows ;;
  MINGW*) machine=windows ;;
  MSYS*) machine=windows ;;
  *) machine="UNKNOWN:${unameOut}" ;;
  esac
  echo $machine
}

get_default_shell_path() {

  case "$SHELL" in
  /bin/bash) echo "$HOME/.bashrc" ;;
  /bin/zsh) echo "$HOME/.zshrc" ;;
  /bin/fish) echo "$HOME/.config/fish/config.fish" ;;
  /bin/dash) echo "$HOME/.profile" ;;
  /usr/bin/tcsh | /bin/tcsh) echo "$HOME/.tcshrc" ;;
  /usr/bin/csh | /bin/csh) echo "$HOME/.cshrc" ;;
  *) echo "$HOME/.bashrc" ;;
  esac
}

install_homebrew() {

  if [ -z "$1" ] || [ "$1" = false ]; then
    return
  fi
  shell_path=$(get_default_shell_path)

  if command -v brew &>/dev/null; then
    echo "Homebrew is already installed."
  else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi

  # Ensure Homebrew's path is added to the shell profile if not already present
  if ! grep -q 'export PATH="/opt/homebrew/bin' "$shell_path"; then
    echo 'export PATH="/opt/homebrew/bin:$PATH"' >>"$shell_path"
  fi

  os=$(get_os)
  if [ "$os" == "linux" ]; then
    if ! grep -q 'brew shellenv' "$shell_path"; then
      echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>"$shell_path"
    fi
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
}

set_default_shell() {
  default_shell="$1"

  if [ -z "$default_shell" ]; then
    return
  fi

  shell_dir="/bin/$default_shell"

  chsh -s $shell_dir
  echo "Successfully set default shell to $shell_dir."
}

set_hostname() {
  local hostname="$1"

  if [ -z "$hostname" ]; then
    return
  fi

  local os=$(get_os)
  echo "Setting hostname to: $hostname"

  if [ "$os" == "mac" ]; then
    sudo scutil --set HostName "$hostname"

    # set localhost name
    if [ ! -z "$local_hostname" ]; then
      sudo -s scutil --set LocalHostName $local_hostname
    fi

    # set computer name
    if [ ! -z "$computer_name" ]; then
      sudo -s scutil --set ComputerName $computer_name
    fi

    dscacheutil -flushcache

  elif [ "$os" == "linux" ]; then
    sudo hostnamectl set-hostname "$hostname"
  else
    echo "Unsupported OS: $os"
    return 1
  fi
}

install_pip_packages() {
  venv_path="$1"
  shift 1
  pip_packages="$@"

  if [ -z "$pip_packages" ]; then
    return
  fi

  if [ -z "$venv_path" ]; then
    venv_path="$VENV_PATH"
  else
    venv_path=$(bash -c "echo $venv_path")
  fi

  echo "VENV PATH: $venv_path"

  # check if venv exists
  if [ -d "$venv_path" ]; then
    source $venv_path/bin/activate
    echo "Activated venv."
  fi

  for package in $pip_packages; do
    pip3 install $package
  done

  parent_path=$(dirname "$venv_path")
  pip3 freeze >"$parent_path/requirements.txt"
}

set_shell_variable() {
  var_name="$1"
  new_value="$2"
  shell_path="$3"

  # check if variable already exists
  if grep -q "^\(export \)\?$var_name=" "$shell_path"; then
    new_value_escaped=$(echo "$new_value" | sed 's/\$/\\\$/g')
    grep "^\(export \)\?$var_name=" "$shell_path" | sed -i '' -E "s|($var_name)=.*|\1=\"$new_value\"|" "$shell_path"
  else
    echo "export $var_name=\"$new_value\"" >>"$shell_path"
  fi

}

get_shell_variable() {
  var_name="$1"
  shell_path="$2"

  value=$(grep -E "^export $var_name=['\"][^'\"]*['\"]" "$shell_path" | sed -E "s/^export $var_name=['\"]([^'\"]*)['\"]/\1/")
  echo "$value"
}

set_venv_path() {
  local venv_path="$1"

  if [ -z "$2" ] || [ "$2" == false ]; then
    return
  fi

  if [ -z "$venv_path" ]; then
    return
  fi

  actual_venv_path=$(bash -c "echo $venv_path")
  python3 -m venv "$actual_venv_path"

  # append to default shell
  shell_path=$(get_default_shell_path)
  var_name="VENV_PATH"
  new_value="$actual_venv_path"

  set_shell_variable "$var_name" "$new_value" "$shell_path"
  echo "Created venv path: $venv_path."
}

install_brew_packages() {
  [ -z "$1$2" ] && return

  install_homebrew true

  for package in $1; do brew install "$package"; done
  for package in $2; do brew install --cask "$package"; done
}

replace_root() {
  local value="$1"
  local root_path="$2"

  # If value starts with '/' and value doesn't start with root path
  if [[ $value == /* && $value != $root_path* ]]; then
    echo "$root_path/${value:1}"
  else
    echo "$value"
  fi
}

set_default_git_dotfiles_directory() {
  # set default GIT_DOTFILES_DIRECTORY directory in shell
  SCRIPT_DIR="$1"

  if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
    GIT_DOTFILES_DIRECTORY="$SCRIPT_DIR"
    var_name="GIT_DOTFILES_DIRECTORY"
    new_value="$GIT_DOTFILES_DIRECTORY"
    shell_path="$(get_default_shell_path)"

    set_shell_variable "$var_name" "$new_value" "$shell_path"
    echo "Set dotfiles directory to: $GIT_DOTFILES_DIRECTORY."
  fi
}
