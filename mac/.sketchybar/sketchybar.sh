if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

export COPY_PLUGINS=1
templates_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/templates"
source "$templates_directory/set_template.sh" "$SKETCHYBAR_TEMPLATE"
