sketchybar_template="$1"

templates_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sketchybar_template_path="$templates_directory/$sketchybar_template"
sketchybarrc_path="$dotfiles_directory/.config/sketchybar/sketchybarrc"

# check if template is an array
