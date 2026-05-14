source "../json.sh"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
extensions_path="$SCRIPT_DIR/vscode/extensions.json"

extensions=$(get_json_value "recommendations.extensions" $extensions_path "")

if ! command -v code &>/dev/null; then
    export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi

for extension in $extensions; do
    code --install-extension "$extension" --force >&2
done

themes_dir="$dotfiles_directory/.config/themes"
themes_path="$themes_dir/theme.sh"
set_settings_path="$SCRIPT_DIR/vscode/set_vscode_settings.sh"
settings_path="$SCRIPT_DIR/vscode/vscode_settings.json"

source "$themes_path"
source "$set_settings_path"
set_vscode_settings
