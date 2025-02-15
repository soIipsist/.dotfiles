if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory=$HOME
fi
destination_directory="$dotfiles_directory/.config/colors"
color_scheme_path="$destination_directory/colors_1.json"

if [ ! -z "$color_scheme" ]; then
    color_scheme_path="$destination_directory/$color_scheme.json"
fi

exported_colors="$destination_directory/colors.sh"

echo "#!/bin/bash" >"$exported_colors"
jq -r 'to_entries | .[] | "export \(.key)=\"\(.value)\""' "$color_scheme_path" >>"$exported_colors"

# Load into current shell session
source "$exported_colors"

# copy vscode settings path
vscode_source_path="$dotfiles_directory/.config/vscode/settings.json"
vscode_destination_path="$HOME/Library/Application Support/Code/User/settings.json"
envsubst <"$vscode_source_path" >"$vscode_destination_path"

# set iterm2 color profile
# source "$dotfiles_directory/.config/iterm2/iterm2.sh"
