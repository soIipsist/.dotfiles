source "../json.sh"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
extensions_path="$SCRIPT_DIR/vscode/extensions.json"
source_settings_path="$SCRIPT_DIR/vscode/vscode_settings.json"
destination_settings_path="$HOME/Library/Application Support/Code/User/settings.json"

extensions=$(get_json_value "recommendations" $extensions_path "")
extensions=""

for extension in $extensions; do
    code --install-extension "$extension" --force >&2
done

# set settings with new theme.sh environment variables
themes_path="$dotfiles_directory/.config/themes/theme.sh"
source "$themes_path"
envsubst <"$source_settings_path" >"$destination_settings_path"
