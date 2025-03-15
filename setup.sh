source "os.sh"

dotfiles=("$@")

os=$(get_os)
echo "Running on $os..."

if [[ "$os" == "windows" ]]; then
    script_path="$os/Test.ps1"
    dotfiles=("$@")

    
    if [ ${#dotfiles[@]} -gt 0 ]; then
        powershell.exe -Command "Start-Process powershell.exe -ArgumentList '-NoProfile', '-NoExit','-ExecutionPolicy Bypass', '-File', '$script_path', '${dotfiles[@]}' -Verb runAs"
    else
        powershell.exe -Command "Start-Process powershell.exe -ArgumentList '-NoProfile', '-NoExit','-ExecutionPolicy Bypass', '-File', '$script_path' -Verb runAs"
    fi

  
else
    cd "$os" || {
        echo "Error: Directory '$os' not found"
        exit 1
    }
    bash "$os.sh" "${dotfiles[@]}"
fi
