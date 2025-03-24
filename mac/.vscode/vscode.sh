source "../json.sh"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
extensions_path="$SCRIPT_DIR/vscode/extensions.json"

extensions=$(get_json_value "recommendations" $extensions_path "")
extensions=""

for extension in $extensions; do
    code --install-extension "$extension" --force >&2
done

themes_path="$dotfiles_directory/.config/themes/theme.sh"
source "$themes_path"

source "$SCRIPT_DIR/vscode/vscode_settings.sh"
set_vscode_settings
