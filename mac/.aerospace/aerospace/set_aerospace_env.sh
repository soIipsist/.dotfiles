function set_aerospace_env() {

    # Get all environment variables starting with "AEROSPACE_"
    VARS=$(env | awk -F= '/^AEROSPACE_/ {print "$" $1}' | tr '\n' ' ')

    # Use envsubst with only those variables
    envsubst "$VARS" <"$SCRIPT_DIR/aerospace/.aerospace.toml" >"$dotfiles_directory/.aerospace.toml"
}
