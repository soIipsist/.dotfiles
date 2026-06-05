if [[ -n "$WSL_DISTRO_NAME" ]]; then
    echo "Copying in WSL..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
else
    skip_dotfiles=true
    return 0
fi
