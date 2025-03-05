if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

if [ -z "$SKETCHYBAR_TEMPLATE" ]; then
    SKETCHYBAR_TEMPLATE="main"
fi

export COPY_PLUGINS=0
SKETCHYBAR_TEMPLATE=("$SKETCHYBAR_TEMPLATE")
templates_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/templates"

source "$templates_directory/set_template.sh" $SKETCHYBAR_TEMPLATE
