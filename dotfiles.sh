get_dotfile_folders() {
  if [ -z "$1" ]; then
    dotfile_folders=$(ls -d .* | grep -v '^\.\.$' | grep -v '^\.$')
  else
    dotfile_folders=$1
  fi
  echo $dotfile_folders
}

install_dotfiles() {
  dotfile_folders=$1
  destination_directory=$2

  if [ -z "$2" ]; then
    echo "'destination directory' argument is required."
    return
  fi

  original_dest=$destination_directory

  for folder in $1; do

    # Collect .sh scripts
    scripts=$(find "$folder" -maxdepth 1 -type f -name "*.sh" 2>/dev/null)

    # Collect dotfiles
    dotfiles=$(find "$folder" -maxdepth 1 -type f ! -name "*.sh" 2>/dev/null)

    for script in $scripts; do
      echo "Executing $script."

      new_dir=$(bash "$script")

      if [ -n "$new_dir" ]; then
        destination_directory="$new_dir"
      else
        destination_directory="$original_dest"
      fi
    done

    for dotfile in $dotfiles; do
      basefile=$(basename "$dotfile")
      sudo -s cp -f "$dotfile" "$destination_directory/$basefile"
      echo "Copied $dotfile to $destination_directory/$basefile."
    done

  done

}
