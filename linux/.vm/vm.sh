destination_directory="$HOME/isos"
source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$destination_directory"
cp -rf "$source_dir/config/*" "$destination_directory"
