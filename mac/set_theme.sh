# change theme on click
if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
  GIT_DOTFILES_DIRECTORY="$HOME/repos/soIipsist/.dotfiles"
fi

echo "Clicked theme: $1" >/tmp/debug.txt
THEME="$1"

# Check if the theme is passed correctly
if [ -z "$THEME" ]; then
  echo "Error: No theme passed." >>/tmp/debug.txt
  exit 1
fi

if [ ! -f "$GIT_DOTFILES_DIRECTORY/os.sh" ]; then
  echo "Error: os.sh not found" >/tmp/debug.txt
  exit 1
fi
source "$GIT_DOTFILES_DIRECTORY/os.sh"

if [ ! -f "$GIT_DOTFILES_DIRECTORY/wallpaper.sh" ]; then
  echo "Error: wallpaper.sh not found" >/tmp/debug.txt
  exit 1
fi

# Define your functions
set_autosuggest_color() {
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

export_theme() {
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

set_sketchybar_template() {
  set_template_path="$dotfiles_directory/.config/sketchybar/plugins/set_template.sh"

  if [ ! -f "$set_template_path" ]; then
    echo "sketchybar: set_template.sh does not exist" >>/tmp/debug.txt
    return 0
  fi

  if [ -n "$SKETCHYBAR_TEMPLATE" ]; then
    source "$set_template_path" "$SKETCHYBAR_TEMPLATE"
  fi
  echo "sketchybar_template $SKETCHYBAR_TEMPLATE" >>/tmp/debug.txt
}

theme_path="$dotfiles_directory/.config/themes/$THEME.json"

if [ ! -f "$theme_path" ]; then
  echo "Theme file does not exist: $theme_path" >>/tmp/debug.txt
  exit 1
fi

export_theme "$theme_path"
source "$dotfiles_directory/.config/themes/theme.sh"

WALLPAPER_PATH=$(replace_root "$WALLPAPER_PATH" "$GIT_DOTFILES_DIRECTORY")
set_wallpaper_mac "$WALLPAPER_PATH"
set_autosuggest_color
set_sketchybar_template

echo "Theme was changed to $THEME." >>/tmp/debug.txt
