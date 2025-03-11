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

# move all environment variables starting with VSCODE_ (except VSCODE_COLOR_THEME) to workbench.color_customizations

envsubst <"$source_settings_path" >"$destination_settings_path"

if [ -n "$VSCODE_COLOR_THEME" ]; then
    jq --arg theme "$VSCODE_COLOR_THEME" '
        ."workbench.colorCustomizations" |= 
        { ($theme): with_entries(select(.key | startswith("[") | not)) }
        + with_entries(select(.key | startswith("[") ))' "$destination_settings_path" >temp.json && mv temp.json "$destination_settings_path"
fi
# remove all empty keys
jq 'del(.. | select(. == ""))' "$destination_settings_path" >temp.json && mv temp.json "$destination_settings_path"
