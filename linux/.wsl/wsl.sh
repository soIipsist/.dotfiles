if [[ -n "$WSL_DISTRO_NAME" ]]; then
    echo "Copying in WSL..."
else
    skip_dotfiles=true
    return 0
fi
