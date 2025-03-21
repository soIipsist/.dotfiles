# sed -E 's/\$([A-Za-z_][A-Za-z0-9_]*)/\1/' <<<"$your_string"
if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi
source "$dotfiles_directory/.config/themes/theme.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get all environment variables starting with "AEROSPACE_"
VARS=$(env | awk -F= '/^AEROSPACE_/ {print "$" $1}' | tr '\n' ' ')

# Use envsubst with only those variables
envsubst "$VARS" <"$SCRIPT_DIR/aerospace/.aerospace.toml" >"$dotfiles_directory/.aerospace.toml"
