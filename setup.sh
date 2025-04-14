source "os.sh"

dotfiles=("$@")

os=$(get_os)
echo "Running on $os..."

if [[ "$os" == "windows" ]]; then
    script_path="$os/Setup.ps1"
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

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
        # set default GIT_DOTFILES_DIRECTORY directory
        GIT_DOTFILES_DIRECTORY="$SCRIPT_DIR"
        var_name="GIT_DOTFILES_DIRECTORY"
        new_value="$GIT_DOTFILES_DIRECTORY"
        shell_path="$(get_default_shell_path)"

        set_shell_variable "$var_name" "$new_value" "$shell_path"
        echo "Set dotfiles directory to: $GIT_DOTFILES_DIRECTORY."
    fi

    bash "$os.sh" "${dotfiles[@]}"

fi
