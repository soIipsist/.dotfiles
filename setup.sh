source "os.sh"

dotfiles=("$@")

os=$(get_os)
echo "Running on $os..."

if [[ "$os" == "windows" ]]; then
    script_path="$os/Setup.ps1"

    if [ ${#dotfiles[@]} -gt 0 ]; then
        powershell.exe Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File \"$script_path\" -Dotfiles ${dotfiles[*]}"
    else
        powershell.exe Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File \"$script_path\""
    fi

else
    cd "$os" || {
        echo "Error: Directory '$os' not found"
        exit 1
    }
    bash "$os.sh" "${dotfiles[@]}"
fi
