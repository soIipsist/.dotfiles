alias python='python3'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ps='ps aux --sort=-%mem | head'

ytdlp_mp4() {

    if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
        echo "Could not find GIT_DOTFILES_DIRECTORY."
        return
    fi

    if [ -n "$VENV_PATH" ]; then
        source $VENV_PATH/bin/activate
    fi

    if [ ! -e "$YTDLP_PATH" ]; then
        curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o "$YTDLP_PATH"
        chmod a+rx "$YTDLP_PATH"
    fi

    python3 $GIT_DOTFILES_DIRECTORY/scripts/ytdlp.py -f video -v mp4 "$@"

    # Deactivate the virtual environment properly
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
    fi
}

ytdlp_mp3() {

    if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
        echo "Could not find GIT_DOTFILES_DIRECTORY."
        return
    fi

    if [ -n "$VENV_PATH" ]; then
        source $VENV_PATH/bin/activate
    fi

    if [ ! -e "$YTDLP_PATH" ]; then
        curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o "$YTDLP_PATH"
        chmod a+rx "$YTDLP_PATH"
    fi

    python3 $GIT_DOTFILES_DIRECTORY/scripts/ytdlp.py -f audio -a mp3 "$@"
    # Deactivate the virtual environment properly
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
    fi
}
