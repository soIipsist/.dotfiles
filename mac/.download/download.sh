UDOWN_DIR=${UDOWN_DIR:-"$HOME/.udown"}
source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo mkdir -p "$UDOWN_DIR"
sudo cp -rf "$source_dir/udown/"* "$UDOWN_DIR"
