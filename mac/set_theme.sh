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

  source "$theme_colors_path"
}

# change theme on click
if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
  GIT_DOTFILES_DIRECTORY="$HOME/repos/soIipsist/.dotfiles"
fi

if [ -z "$dotfiles_directory" ]; then
  dotfiles_directory="$HOME"
fi

THEME="$1"
echo "theme: $THEME" >>/tmp/debug.txt

set_template_path="$dotfiles_directory/.config/sketchybar/plugins/set_template.sh"
theme_path="$dotfiles_directory/.config/themes/$THEME.json"

source "$GIT_DOTFILES_DIRECTORY/wallpaper.sh"
source "$GIT_DOTFILES_DIRECTORY/os.sh"

echo "THEME: $THEME" >>/tmp/debug.txt

# export_theme "$theme_path"

# WALLPAPER_PATH=$(replace_root "$WALLPAPER_PATH" "$GIT_DOTFILES_DIRECTORY")
# set_wallpaper_mac "$WALLPAPER_PATH"
# set_autosuggest_color

# if [ -n "$SKETCHYBAR_TEMPLATE" ]; then
#   source "$set_template_path" "$SKETCHYBAR_TEMPLATE"
# fi

# # source colors
# source "$dotfiles_directory/.config/themes/theme.sh"
# echo "Theme was changed to $THEME." >>/tmp/debug.txt
# echo "WALLPAPER_PATH: $WALLPAPER_PATH."
