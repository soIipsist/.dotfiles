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

# change theme on click
THEME="$1"

if [ -z "$THEME" ]; then
  exit 0
fi

set_template_path="$dotfiles_directory/.config/sketchybar/plugins/set_template.sh"
theme_path="$dotfiles_directory/.config/themes/$THEME.json"

export_theme "$theme_path"

WALLPAPER_PATH=$(replace_root "$WALLPAPER_PATH" "$GIT_DOTFILES_DIRECTORY")
set_wallpaper "$WALLPAPER_PATH"
set_autosuggest_color

if [ -n "$SKETCHYBAR_TEMPLATE" ]; then
  # sketchybar --trigger
  source "$set_template_path" "$SKETCHYBAR_TEMPLATE"
fi

if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
  echo "GIT DOTFILES DIRECTORY was not defined."
  return
fi

source "$GIT_DOTFILES_DIRECTORY/mac/.vscode/vscode/vscode_settings.sh"
source "$GIT_DOTFILES_DIRECTORY/mac/.vscode/vscode/vscode_settings.sh"
set_vscode_settings

# set aerospace settings
VARS=$(env | awk -F= '/^AEROSPACE_/ {print "$" $1}' | tr '\n' ' ')
envsubst "$VARS" <"$GIT_DOTFILES_DIRECTORY/mac/.aerospace/aerospace/.aerospace.toml" >"$dotfiles_directory/.aerospace.toml"
aerospace reload-config

echo "Theme was changed to $THEME."
echo "WALLPAPER_PATH: $WALLPAPER_PATH."
