SCRIPTS_DIRECTORY="$HOME/repos"
DOWNLOADS_PATH="downloads.txt"

download() {
    args=("$@")

    for i in "${!args[@]}"; do
        args[$i]="${args[$i]//\"/\\\"}"
    done

    SCRIPT_PATH="$SCRIPTS_DIRECTORY/downloader.py"
    cmd="python3 \"$SCRIPT_PATH\" \"$args\""
    echo $cmd
}

while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        download "$line"
    fi
done <"$DOWNLOADS_PATH"
