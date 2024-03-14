install_homebrew() {
  # check if homebrew is not in $PATH
  if [[ ":$PATH:" == *"/opt/home:"* ]]; then
    echo "Homebrew was already installed."
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    echo "export PATH=/opt/homebrew/bin:$PATH" >>~/.zshrc
    source ~/.zshrc
  fi
}

install_brewfile() {
  if [ -z $brewfile_path ]; then
    brewfile_path=$(pwd)/Brewfile
  fi

  echo $brewfile_path
  # brew bundle --file $brewfile_path
}
