source "../json.sh"

set_vscode_theme() {
    vscode_source_path="$dotfiles_directory/.config/vscode/vscode_settings.json"
    vscode_destination_path="$HOME/Library/Application Support/Code/User/settings.json"

    if [ -z "$1" ]; then
        vscode_source_path="$1" # if argument is defined, set it as vscode source path
    fi

    if [ -f "$vscode_source_path" ]; then
        envsubst <"$vscode_source_path" >"$vscode_destination_path"
    fi
}

if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

destination_directory="$dotfiles_directory/.config/vscode"

source_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
extensions_path="$source_directory/extensions.json"
settings_path="$source_directory/vscode_settings.json"
default_vs_code_path="$HOME/Library/Application Support/Code/User/settings.json"

extensions=$(get_json_value "recommendations" $extensions_path "")
extensions=""

for extension in $extensions; do
    code --install-extension "$extension" --force >&2
done

# replace colors with environment variables
colors_path="$dotfiles_directory/.config/themes/theme.sh"
source "$colors_path"
envsubst <"$settings_path" >"$default_vs_code_path"
