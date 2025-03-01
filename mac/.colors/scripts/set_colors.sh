# sets default color scheme based on $color_scheme provided

if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
    GIT_DOTFILES_DIRECTORY="$HOME/repos/soIipsist/.dotfiles"
fi

if [ ! -z "$1" ]; then
    color_scheme="$1"
fi

if [ -z "$color_scheme" ]; then
    color_scheme="main_theme"
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

# python "/Users/p/repos/soIipsist/.dotfiles/mac/.iterm2/scripts/set_preset.py"

# set wallpaper
if [ -n "$WALLPAPER_PATH" ]; then
    script="$GIT_DOTFILES_DIRECTORY/mac/prefs.scpt"
    osascript $script $WALLPAPER_PATH
fi

# set sketchybar template
if [ -n "$SKETCHYBAR_TEMPLATE" ]; then
    templates_directory="$GIT_DOTFILES_DIRECTORY/mac/.sketchybar/templates"
    template_path="$templates_directory/$SKETCHYBAR_TEMPLATE"

    # copy sketchybar template, if it the template path exists
    if [ -f "$template_path" ]; then
        cp -f "$template_path" "$dotfiles_directory/.config/sketchybar/sketchybarrc"
        sketchybar --reload
    else
        # copy bottom and top parts
        cp -f "$templates_directory/bottom_$SKETCHYBAR_TEMPLATE" "$dotfiles_directory/.config/bottombar/sketchybarrc"
        cp -f "$templates_directory/top_$SKETCHYBAR_TEMPLATE" "$dotfiles_directory/.config/sketchybar/sketchybarrc"

        sketchybar --reload
        bottombar --reload
    fi
fi

if [ -n "$ITERM2_AUTOSUGGEST_COLOR" ]; then # replace existing autosuggest color, if it exists
    zshrc_path="$dotfiles_directory/.zshrc"
    var_name="ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"
    new_value="fg=$ITERM2_AUTOSUGGEST_COLOR"

    if grep -q "^$var_name=" "$zshrc_path"; then
        sed -i '' "s|^$var_name=.*|$var_name=\"$new_value\"|" "$zshrc_path"
    else
        echo "$var_name=\"$new_value\"" >>"$zshrc_path"
    fi
fi
