# sets default color scheme based on $theme provided

if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
    GIT_DOTFILES_DIRECTORY="$HOME/repos/soIipsist/.dotfiles"
fi

if [ ! -z "$1" ]; then
    theme="$1"
fi

if [ -z "$theme" ]; then
    theme="main"
fi

templates_directory="$GIT_DOTFILES_DIRECTORY/mac/.sketchybar/templates"
destination_directory="$dotfiles_directory/.config/colors"
theme_path="$destination_directory/$theme.json"
exported_colors="$destination_directory/colors.sh"

# export from theme.json file and source colors.sh

echo "#!/bin/bash" >"$exported_colors"
jq -r 'to_entries | .[] | 
  if (.value | type == "string") then 
    "export \(.key)=\"\(.value)\""
  else 
    "export \(.key)=\(.value)"
  end' "$theme_path" >>"$exported_colors"

source "$exported_colors"

# copy vscode settings path
vscode_source_path="$dotfiles_directory/.config/vscode/vscode_settings.json"
vscode_destination_path="$HOME/Library/Application Support/Code/User/settings.json"

if [ -f "$vscode_source_path" ]; then
    envsubst <"$vscode_source_path" >"$vscode_destination_path"
fi

# copy tmux config path
tmux_config_path="$GIT_DOTFILES_DIRECTORY/mac/.tmux/.tmux.conf"
tmux_destination_path="$HOME/.tmux/.tmux.conf"

if [ -f "$tmux_config_path" ]; then
    envsubst <"$tmux_config_path" >"$tmux_destination_path"
fi

# set wallpaper
if [ -n "$WALLPAPER_PATH" ]; then
    if [[ $WALLPAPER_PATH == /* ]]; then
        WALLPAPER_PATH="$GIT_DOTFILES_DIRECTORY/${WALLPAPER_PATH:1}"
    fi

    script="$GIT_DOTFILES_DIRECTORY/mac/prefs.scpt"
    osascript $script $WALLPAPER_PATH
fi

# set sketchybar template
if [ -n "$SKETCHYBAR_TEMPLATE" ]; then
    export COPY_PLUGINS=1
    source "$templates_directory/set_template.sh" "$SKETCHYBAR_TEMPLATE"
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
