VM_DIR=${VM_DIR:-"$HOME/isos"}
source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$VM_DIR"
cp -rf "$source_dir/config/"* "$VM_DIR"

echo
echo "Fix permissions so QEMU can read your ISOs?"
echo "(This adds you to libvirt-qemu group and fixes $VM_DIR) (y/N)"
read -r answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
    sudo usermod -aG libvirt-qemu "$USER"
    sudo chgrp -R libvirt-qemu "$VM_DIR"
    sudo chmod -R g+rwX "$VM_DIR"
    echo "Permissions fixed. (Log out/in for group change to apply)"
else
    echo "Skipped permission fix."
fi
