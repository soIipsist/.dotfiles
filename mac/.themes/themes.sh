if [ -z "$dotfiles_directory" ]; then
  dotfiles_directory="$HOME"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
destination_directory="$dotfiles_directory/.config/themes"

rm "$destination_directory"/*.json # removes all existing .json files
theme_path="$SCRIPT_DIR/main.json"

# export theme colors

export_theme() {
  theme_path="$1" # some theme.json file
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
