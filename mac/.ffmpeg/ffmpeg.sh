install_ffmpeg() {
    set -e

    BASE="$HOME/ffmpeg"
    BIN_DIR="$BASE/macos"

    mkdir -p "$BIN_DIR"

    tmpdir="$(mktemp -d)"

    echo "Installing ffmpeg..."

    curl -L "https://evermeet.cx/ffmpeg/getrelease/zip" \
        -o "$tmpdir/ffmpeg.zip"
    unzip -q "$tmpdir/ffmpeg.zip" -d "$tmpdir"
    mv -f "$tmpdir/ffmpeg" "$BIN_DIR/ffmpeg"
    chmod +x "$BIN_DIR/ffmpeg"

    echo "Installing ffprobe..."

    curl -L "https://evermeet.cx/ffmpeg/getrelease/ffprobe/zip" \
        -o "$tmpdir/ffprobe.zip"
    unzip -q "$tmpdir/ffprobe.zip" -d "$tmpdir"
    mv -f "$tmpdir/ffprobe" "$BIN_DIR/ffprobe"
    chmod +x "$BIN_DIR/ffprobe"

    rm -rf "$tmpdir"

    echo "Installed to: $BIN_DIR"
}

install_ffmpeg