# sets default color scheme based on $color_scheme provided

if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
    GIT_DOTFILES_DIRECTORY="$HOME/repos/soIipsist/.dotfiles"
fi

if [ -z "$color_scheme" ]; then
    color_scheme="colors_1"
fi

if [ ! -z "$1" ]; then
    color_scheme="$1"
fi

destination_directory="$dotfiles_directory/.config/colors"
color_scheme_path="$destination_directory/$color_scheme.json"
exported_colors="$destination_directory/colors.sh"

echo "#!/bin/bash" >"$exported_colors"
jq -r 'to_entries | .[] | "export \(.key)=\"\(.value)\""' "$color_scheme_path" >>"$exported_colors"

# Load into current shell session
source "$exported_colors"

# copy vscode settings path
vscode_source_path="$dotfiles_directory/.config/vscode/vscode_settings.json"
vscode_destination_path="$HOME/Library/Application Support/Code/User/settings.json"

if [ -f "$vscode_source_path" ]; then
    envsubst <"$vscode_source_path" >"$vscode_destination_path"
fi

# load iterm2 colors
iterm2_path="$GIT_DOTFILES_DIRECTORY/mac/.iterm2/scripts"
generate_plist_path="$iterm2_path/generate_plist.sh"

if [ -f "$generate_plist_path" ]; then
    source "$generate_plist_path"
fi

python "/Users/p/repos/soIipsist/.dotfiles/mac/.iterm2/scripts/set_preset.py"
