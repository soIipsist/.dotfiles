function set_aerospace_env() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Get all environment variables starting with "AEROSPACE_"
    VARS=$(env | awk -F= '/^AEROSPACE_/ {print "$" $1}' | tr '\n' ' ')

    # Use envsubst with only those variables
    envsubst "$VARS" <"$SCRIPT_DIR/.aerospace.toml" >"$dotfiles_directory/.aerospace.toml"
    echo "Copied $SCRIPT_DIR/.aerospace.toml to $dotfiles_directory/.aerospace.toml."
}
