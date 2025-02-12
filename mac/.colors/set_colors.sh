if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory=$HOME
fi
destination_directory="$dotfiles_directory/.config/colors"
color_scheme_path="$destination_directory/colors_1.json"

if [ ! -z "$color_scheme" ]; then
    color_scheme_path="$destination_directory/$color_scheme.json"
fi

export_file="$destination_directory/colors.sh"

echo "#!/bin/bash" >"$export_file"
jq -r 'to_entries | .[] | "export \(.key)=\"\(.value)\""' "$color_scheme_path" >>"$export_file"

# Load into current shell session
source "$export_file"
