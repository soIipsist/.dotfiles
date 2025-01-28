get_dotfile_folders() {
  if [ -z "$1" ]; then
    dotfile_folders=$(ls -d .* | grep -v '^\.\.$' | grep -v '^\.$')
  else
    dotfile_folders=$1
  fi
  echo $dotfile_folders
}

install_dotfiles() {
  dotfiles_directory=$1
  dotfile_folders=$2
  scripts=$3
  excluded_scripts=$4

  if [ -z "$1" ]; then
    dotfiles_directory=$HOME
    return
  fi

  original_dest=$dotfiles_directory

  for folder in $dotfile_folders; do

    # Collect .sh scripts
    dotfile_scripts=$(find "$folder" -maxdepth 1 -type f -name "*.sh" 2>/dev/null)

    if [[ -n "$scripts" ]]; then
      dotfile_scripts="${scripts[@]}"
      echo "Scripts is not empty ${dotfile_scripts[@]}"
    fi

    # Collect dotfiles
    dotfiles=$(find "$folder" -maxdepth 1 -type f ! -name "*.sh" 2>/dev/null)
    dotfiles_directory="$original_dest"

    for script in $dotfile_scripts; do

      # check if script is in excluded_scripts or is not in scripts
      if [[ " ${excluded_scripts[*]} " =~ " ${script} " ]]; then
        echo "EXCLUDED: $script"
        continue
      fi

      echo "Executing $script."

      new_dir=$(bash "$script")

      if [ -n "$new_dir" ]; then
        dotfiles_directory="$new_dir"
      else
        dotfiles_directory="$original_dest"
      fi
    done

    for dotfile in $dotfiles; do
      basefile=$(basename "$dotfile")
      if [ ! -d "$dotfiles_directory" ]; then
        mkdir -p "$dotfiles_directory"
        echo "Created directory: $dotfiles_directory"
      fi

      cp -f "$dotfile" "$dotfiles_directory/$basefile"
      echo "Copied $dotfile to $dotfiles_directory/$basefile."

      if [[ $basefile == *.sh ]]; then
        source "$dotfiles_directory/$basefile"
      fi

    done

  done

}
