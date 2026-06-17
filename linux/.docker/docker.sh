SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
destination_directory="$HOME/.containers"
CONTAINERS_DIR="$SCRIPT_DIR/.containers"

mkdir -p "$destination_directory"
cp -R "$CONTAINERS_DIR"/. "$destination_directory"/

find "$destination_directory" \( -name "*.yaml" -o -name "*.yml" \) -type f | while read -r file; do
    dir=$(dirname "$file")
    mv "$file" "$dir/compose.yaml"
done