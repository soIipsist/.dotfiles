alias python='python3'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ps='ps aux --sort=-%mem | head'

ytdlp_mp3() {

    if [ -z "$SCRIPTS_DIRECTORY" ]; then
        SCRIPTS_DIRECTORY="$GIT_DOTFILES_DIRECTORY/scripts"
    fi
    SCRIPT_PATH="$SCRIPTS_DIRECTORY/ytdlp.py"

    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "Could not find ytdlp.py."
        return
    fi

    if [ ! -e "$YTDLP_PATH" ]; then
        echo "Cloning yt-dlp..."
        mkdir -p "$(dirname "$YTDLP_PATH")"
        curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o "$YTDLP_PATH"
        chmod a+rx "$YTDLP_PATH"
    fi

    if [ -n "$VENV_PATH" ]; then
        source $VENV_PATH/bin/activate
    fi

    python3 $SCRIPT_PATH -f audio "$@"

    # Deactivate the virtual environment properly
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
    fi
}

get_codec() {
    if [ ! -f "$1" ]; then
        echo "File not found: $1" >&2
        return 1
    fi
    codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$1")
    echo "$codec"
}

ytdlp_mp4() {

    if [ -z "$SCRIPTS_DIRECTORY" ]; then
        SCRIPTS_DIRECTORY="$GIT_DOTFILES_DIRECTORY/scripts"
    fi
    SCRIPT_PATH="$SCRIPTS_DIRECTORY/ytdlp.py"

    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "Could not find ytdlp.py."
        return
    fi

    if [ ! -e "$YTDLP_PATH" ]; then
        echo "Cloning yt-dlp..."
        mkdir -p "$(dirname "$YTDLP_PATH")"
        curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o "$YTDLP_PATH"
        chmod a+rx "$YTDLP_PATH"
    fi

    if [ -n "$VENV_PATH" ]; then
        source $VENV_PATH/bin/activate
    fi

    python3 $SCRIPT_PATH -f video "$@"

    # Deactivate the virtual environment properly
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
    fi
}
