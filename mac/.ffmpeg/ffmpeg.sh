install_ffmpeg() {
    if command -v ffmpeg &>/dev/null; then
        return
    fi
    brew install ffmpeg

}

install_ffmpeg