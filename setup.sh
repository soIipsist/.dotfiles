source "os.sh"

dotfiles=("$@")

os=$(get_os)

if [[ "$os" == "windows" ]]; then
    echo "Running on Windows..."
    script_path="$os/Setup.ps1"
    powershell.exe Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File \"$script_path\""
else
    echo "Running on $os..."
    cd "$os" || {
        echo "Error: Directory '$os' not found"
        exit 1
    }
    bash "$os.sh" "${dotfiles[@]}"
fi
