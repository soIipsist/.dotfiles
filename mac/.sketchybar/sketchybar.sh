if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

if [ -z "$SKETCHYBAR_TEMPLATE" ]; then
    SKETCHYBAR_TEMPLATE="main"
fi

copy_plugins=1
source "$templates_directory/set_template.sh" "$SKETCHYBAR_TEMPLATE" "$copy_plugins"
