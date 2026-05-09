SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$SCRIPT_DIR/.secret_aliases" ]; then
    touch "$SCRIPT_DIR/.secret_aliases"
fi
