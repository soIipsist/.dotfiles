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
  echo "export dotfiles_directory=$dotfiles_directory" >>"$theme_colors_path"

  source "$theme_colors_path"

}

if [ -z "$dotfiles_directory" ]; then
  dotfiles_directory="$HOME"
fi

source "$dotfiles_directory/.config/themes/set_aerospace_env.sh"
source "$dotfiles_directory/.config/themes/set_vscode_settings.sh"
source "$dotfiles_directory/.config/themes/set_iterm2.sh"
source "$dotfiles_directory/.config/sketchybar/plugins/set_template.sh"

# change theme on click
THEME="$1"

if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
  echo "GIT DOTFILES DIRECTORY was not defined."
  return
fi

if [ -z "$THEME" ]; then
  exit 0
fi

# get theme.json path
theme_path="$dotfiles_directory/.config/themes/$THEME.json"
export_theme "$theme_path"
set_wallpaper "$WALLPAPER_PATH"
set_autosuggest_color
set_sketchybar_template "$set_template_path" "$SKETCHYBAR_TEMPLATE"
set_vscode_settings
aerospace reload-config

echo "Theme was changed to $THEME."
echo "WALLPAPER_PATH: $WALLPAPER_PATH."
