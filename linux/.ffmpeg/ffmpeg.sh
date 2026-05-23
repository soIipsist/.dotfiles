install_ffmpeg() {
    set -e

    FFMPEG_PREFIX="/usr/local/ffmpeg"
    BIN_LINK="/usr/local/bin/ffmpeg"

    URL="https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz"

    echo "Installing FFmpeg (stable Linux build)..."

    tmpdir="$(mktemp -d)"

    curl -L "$URL" -o "$tmpdir/ffmpeg.tar.xz"
    tar -xf "$tmpdir/ffmpeg.tar.xz" -C "$tmpdir"

    extracted_dir="$(find "$tmpdir" -maxdepth 1 -type d -name "*ffmpeg*static*" | head -n 1)"

    if [ -z "$extracted_dir" ]; then
        echo "Failed to extract ffmpeg"
        exit 1
    fi

    sudo rm -rf "$FFMPEG_PREFIX"
    sudo mkdir -p "$FFMPEG_PREFIX"

    sudo cp -r "$extracted_dir/"* "$FFMPEG_PREFIX/"

    sudo chmod +x "$FFMPEG_PREFIX/ffmpeg"
    sudo chmod +x "$FFMPEG_PREFIX/ffprobe"

    # ensure system-wide command exists
    sudo ln -sf "$FFMPEG_PREFIX/ffmpeg" "$BIN_LINK"

    rm -rf "$tmpdir"

    echo "Installed to: $FFMPEG_PREFIX"
    echo "Symlinked: $BIN_LINK"
}

install_ffmpeg