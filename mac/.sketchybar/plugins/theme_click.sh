if [ -z "$dotfiles_directory" ]; then
    export dotfiles_directory="$HOME"
fi
source "/Users/p/repos/soIipsist/.dotfiles/mac/set_theme.sh" "$1"

reload_path="$PLUGIN_DIR/reload.sh"
if [ ! -f "$reload_path" ]; then

fi
source "$PLUGIN_DIR/reload.sh"
