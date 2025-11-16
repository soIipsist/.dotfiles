VM_DIR=${VM_DIR:-"$HOME/isos"}
source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$VM_DIR"
cp -rf "$source_dir/config/"* "$VM_DIR"
