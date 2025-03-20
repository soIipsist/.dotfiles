# sed -E 's/\$([A-Za-z_][A-Za-z0-9_]*)/\1/' <<<"$your_string"
if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi
source "$dotfiles_directory/.config/themes/theme.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sed -i '' -E 's/\$([A-Za-z_][A-Za-z0-9_]*)/${!\1}/g' "$dotfiles_directory/config.toml"
