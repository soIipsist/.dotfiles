install_ytdlp(){
    YTDLP_PATH="$HOME/ytdlp/yt-dlp_macos"

    if [ ! -e "$YTDLP_PATH" ]; then
        echo "Cloning yt-dlp..."
        mkdir -p "$(dirname "$YTDLP_PATH")"
        release_name=$(basename $YTDLP_PATH)
        curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/$release_name -o "$YTDLP_PATH"
        chmod a+rx "$YTDLP_PATH"
    fi
}

install_ytdlp