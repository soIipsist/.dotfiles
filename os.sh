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

set_default_shell(){

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
