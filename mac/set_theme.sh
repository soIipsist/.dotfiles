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
  echo "export GIT_DOTFILES_DIRECTORY=$GIT_DOTFILES_DIRECTORY" >>"$theme_colors_path"

  source "$theme_colors_path"

}

function set_theme() {

  if [ -z "$dotfiles_directory" ]; then
    export dotfiles_directory="$HOME"
  fi

  THEME="$1"

  if [ -z "$THEME" ]; then
    return
  fi

  source "$GIT_DOTFILES_DIRECTORY/os.sh"
  source "$GIT_DOTFILES_DIRECTORY/mac/wallpaper.sh"
  source "$GIT_DOTFILES_DIRECTORY/mac/.aerospace/aerospace/set_aerospace.sh"
  source "$GIT_DOTFILES_DIRECTORY/mac/.vscode/vscode/set_vscode_settings.sh"
  source "$GIT_DOTFILES_DIRECTORY/mac/.iterm2/iterm2/set_iterm2.sh"
  source "$dotfiles_directory/.config/sketchybar/plugins/set_template.sh"

  # get theme.json path
  theme_path="$dotfiles_directory/.config/themes/$THEME.json"
  export_theme "$theme_path"

  # set wallpaper
  WALLPAPER_PATH=$(replace_root "$WALLPAPER_PATH" "$GIT_DOTFILES_DIRECTORY")
  set_wallpaper "$WALLPAPER_PATH"

  # set iterm2
  set_autosuggest_color

  # set sketchybar
  set_sketchybar_template "$SKETCHYBAR_TEMPLATE"

  # set vscode
  set_vscode_settings

  # set aerospace
  set_aerospace_env
  aerospace reload-config

  echo "Theme was changed to $THEME."
  echo "DOTFILES $dotfiles_directory $GIT_DOTFILES_DIRECTORY"
}
