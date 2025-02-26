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

  if [ -z "$1" ] || [ "$1" == false ]; then
    return
  fi
  shell_path=$(get_default_shell_path)

  # check if homebrew is not in $PATH
  if [[ ":$PATH:" == *":/opt/homebrew/bin:"* ]]; then
    echo "Homebrew was already installed."
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    echo "export PATH=/opt/homebrew/bin:$PATH" >>$shell_path
    source $shell_path
  fi
}

set_default_shell() {

  if [ -z $default_shell ]; then
    return
  fi

  shell_dir="/bin/$default_shell"

  chsh -s $shell_dir
  echo "Successfully set default shell to $shell_dir."
}

set_hostname() {
  if [ -z "$hostname" ]; then
    return
  fi

  echo "Setting hostname to: $hostname"

  if [ $os == 'mac' ]; then
    sudo -s scutil --set HostName $hostname

    # set localhost name
    if [ ! -z $local_hostname ]; then
      sudo -s scutil --set LocalHostName $local_hostname
    fi

    # set computer name
    if [ ! -z $computer_name ]; then
      sudo -s scutil --set ComputerName $computer_name
    fi

    dscacheutil -flushcache

  elif [ $os == 'linux' ]; then
    sudo hostnamectl set-hostname $hostname
  else
    return
  fi
}

install_pip_packages() {
  pip_packages=$1

  if [ -z "$pip_packages" ]; then
    return
  fi

  # create venv if it doesn't exist
  cd $HOME
  if [ ! -d "$HOME/venv" ]; then
    python -m venv venv
  fi

  source venv/bin/activate

  for package in $pip_packages; do
    pip install $package
  done

}
