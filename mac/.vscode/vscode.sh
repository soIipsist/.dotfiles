source "../json.sh"
destination_directory="$dotfiles_directory/.config/vscode"

source_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
extensions_path="$source_directory/extensions.json"
settings_path="$source_directory/settings.json"
default_vs_code_path="$HOME/Library/Application Support/Code/User/settings.json"

extensions=$(get_json_value "recommendations" $extensions_path "")

for extension in $extensions; do
    code --install-extension "$extension" --force >&2
done

# replace colors with environment variables
colors_path="$dotfiles_directory/.config/colors/colors.sh"
source "$colors_path"
envsubst <"$settings_path" >"$default_vs_code_path"
echo $destination_directory
