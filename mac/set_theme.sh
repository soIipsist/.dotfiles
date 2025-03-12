# Define your functions
function set_autosuggest_color() {
  if [ -z "$ITERM2_AUTOSUGGEST_COLOR" ]; then
    return 0
  fi

  zshrc_path="$dotfiles_directory/.zshrc"
  var_name="ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"
  new_value="fg=$ITERM2_AUTOSUGGEST_COLOR"

  if grep -q "^$var_name=" "$zshrc_path"; then
    sed -i '' "s|^$var_name=.*|$var_name=\"$new_value\"|" "$zshrc_path"
  else
    echo "$var_name=\"$new_value\"" >>"$zshrc_path"
  fi
}

function export_theme() {
  theme_path="$1"
  icons_path="$(dirname $theme_path)/icons.json"
  theme_colors_path="$dotfiles_directory/.config/themes/theme.sh"

  SELECTED_THEME="$theme_path"

  if [ ! -f "$theme_colors_path" ]; then
    touch "$theme_colors_path"
  fi

  echo "#!/bin/bash" >"$theme_colors_path"
  jq -r 'to_entries | .[] | 
  if (.value | type == "string") then 
    "export \(.key)=\"\(.value)\""
  elif (.value | type == "array") then 
    "export \(.key)=\"" + (.value | join(" ")) + "\""
  else 
    "export \(.key)=\(.value)"
  end' "$theme_path" >>"$theme_colors_path"

  jq -r 'to_entries | .[] | 
  if (.value | type == "string") then 
    "export \(.key)=\"\(.value)\""
  elif (.value | type == "array") then 
    "export \(.key)=\"" + (.value | join(" ")) + "\""
  else 
    "export \(.key)=\(.value)"
  end' "$icons_path" >>"$theme_colors_path"

  echo "export SELECTED_THEME=$SELECTED_THEME" >>"$theme_colors_path"
  source "$theme_colors_path"

}

function replace_root() {
  local value="$1"
  local root_path="$2"

  # If value starts with '/' and value doesn't start with root path
  if [[ $value == /* && $value != $root_path* ]]; then
    echo "$root_path/${value:1}"
  else
    echo "$value"
  fi
}

function set_wallpaper() {

  wallpaper_path="$1"

  if [ -z "$wallpaper_path" ]; then
    return
  fi

  osascript $GIT_DOTFILES_DIRECTORY/mac/wallpaper.scpt $wallpaper_path
  echo "Set wallpaper to: $wallpaper_path"

}

# change theme on click
if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
  GIT_DOTFILES_DIRECTORY="$HOME/repos/soIipsist/.dotfiles"
fi

if [ -z "$dotfiles_directory" ]; then
  dotfiles_directory="$HOME"
fi

THEME="$1"

if [ -z "$THEME" ]; then
  exit 0
fi

set_template_path="$dotfiles_directory/.config/sketchybar/plugins/set_template.sh"
theme_path="$dotfiles_directory/.config/themes/$THEME.json"

# source theme
export_theme "$theme_path"

WALLPAPER_PATH=$(replace_root "$WALLPAPER_PATH" "$GIT_DOTFILES_DIRECTORY")
set_wallpaper "$WALLPAPER_PATH"
set_autosuggest_color

if [ -n "$SKETCHYBAR_TEMPLATE" ]; then
  # sketchybar --trigger
  source "$set_template_path" "$SKETCHYBAR_TEMPLATE"
fi

# set vscode theme
source_vscode_settings_path="$GIT_DOTFILES_DIRECTORY/mac/.vscode/vscode/vscode_settings.json"
destination_vscode_settings_path="$HOME/Library/Application Support/Code/User/settings.json"
envsubst <"$source_vscode_settings_path" >"$destination_vscode_settings_path"

if [ -n "$VSCODE_COLOR_THEME" ]; then
  jq --arg theme "$VSCODE_COLOR_THEME" '
        ."workbench.colorCustomizations" |= 
        { ($theme): with_entries(select(.key | startswith("[") | not)) }
        + with_entries(select(.key | startswith("[") ))' "$destination_vscode_settings_path" >temp.json && mv temp.json "$destination_vscode_settings_path"
fi
# remove all empty keys
jq 'del(.. | select(. == ""))' "$destination_vscode_settings_path" >temp.json && mv temp.json "$destination_vscode_settings_path"

# set tmux theme
source_tmux_conf="$GIT_DOTFILES_DIRECTORY/mac/.tmux/tmux/.tmux.conf"
destination_tmux_conf="$dotfiles_directory/.tmux.conf"
envsubst <"$source_tmux_conf" >"$destination_tmux_conf"

echo "Theme was changed to $THEME."
echo "WALLPAPER_PATH: $WALLPAPER_PATH."
