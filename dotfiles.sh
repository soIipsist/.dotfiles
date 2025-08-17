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
  fi

  if [ -z "$2" ]; then
    return
  fi

  original_dest="$dotfiles_directory"

  for folder in $dotfile_folders; do

    # Collect .sh scripts
    dotfile_scripts=$(find "$folder" -maxdepth 1 -type f -name "*.sh" 2>/dev/null)

    if [[ -n "$scripts" ]]; then
      dotfile_scripts="${scripts[@]}"
    fi

    dotfiles_directory="$original_dest"

    for script in $dotfile_scripts; do

      script_basename=$(basename $script)
      script="$PWD/$folder/$script_basename"

      # check if script is in excluded_scripts or is not in scripts
      if [[ " ${excluded_scripts[*]} " =~ " ${script} " || " ${excluded_scripts[*]} " =~ " ${script_basename} " ]]; then
        continue
      fi

      if ! ls "$script" &>/dev/null; then
        continue
      fi

      echo "Executing $script."
      source "$script"

      if [ -n "$destination_directory" ]; then # set destination directory
        dotfiles_directory="$destination_directory"
      fi
    done

    dotfiles=$(find "$folder" -maxdepth 1 -type f ! -name "*.sh" 2>/dev/null)

    for dotfile in $dotfiles; do
      basefile=$(basename "$dotfile")

      if [ ! -d "$dotfiles_directory" ]; then
        mkdir -p "$dotfiles_directory"
        echo "Created directory: $dotfiles_directory"
      fi

      cp -f "$dotfile" "$dotfiles_directory/$basefile"
      echo "Copied $dotfile to $dotfiles_directory/$basefile."

    done
    destination_directory=""
  done

  dotfiles_directory="$original_dest"
}

copy_scripts() {
  dotfile_scripts_dir="$1"
  scripts_directory="$2"

  if [ -z "$scripts_directory" ]; then
    return
  fi

  scripts=$(find "$dotfile_scripts_dir" -maxdepth 1 -type f ! -name "*.ps1")
  dirs=$(find "$dotfile_scripts_dir" -maxdepth 1 -type d ! -name "tests")

  if [ ! -d "$scripts_directory" ]; then
    mkdir -p "$scripts_directory"
    echo "Created directory: $scripts_directory"
  fi

  for script in $scripts; do
    cp -f "$script" "$scripts_directory"
    echo "Copied $script to $scripts_directory."
  done

  for dir in $dirs; do
    cp -rf "$dir" "$scripts_directory"
    echo "Copied $dir to $scripts_directory."
  done
}
