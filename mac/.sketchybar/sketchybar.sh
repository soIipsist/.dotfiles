if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

if [ -z "$SKETCHYBAR_TEMPLATE" ]; then
    SKETCHYBAR_TEMPLATE="main"
fi

COPY_PLUGINS=1
source "$templates_directory/set_template.sh" "$SKETCHYBAR_TEMPLATE" "$COPY_PLUGINS"
