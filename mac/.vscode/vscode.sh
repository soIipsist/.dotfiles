source "../json.sh"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
extensions_path="$SCRIPT_DIR/vscode/extensions.json"

extensions=$(get_json_value "recommendations" $extensions_path "")
extensions=""

for extension in $extensions; do
    code --install-extension "$extension" --force >&2
done

themes_dir="$dotfiles_directory/.config/themes"
themes_path="$themes_dir/theme.sh"
set_settings_path="$SCRIPT_DIR/vscode/set_vscode_settings.sh"
settings_path="$SCRIPT_DIR/vscode/vscode_settings.json"

source "$themes_path"
source "$settings_path"
set_vscode_settings

cp -f "$set_settings_path" "$themes_dir"
chmod +x "$dotfiles_directory/.config/themes/set_vscode_settings.sh"

cp -f "$settings_path" "$themes_dir"
