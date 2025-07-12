SCRIPTS_DIRECTORY="$HOME/repos"
DOWNLOADS_PATH="downloads.txt"

download() {
    args="$1"
    new_arr=()

    for arg in $args; do
        escaped="${arg//\"/\\\"}"
        new_arr+=("$escaped")
    done

    SCRIPT_PATH="$SCRIPTS_DIRECTORY/downloader.py"
    cmd="python3 \"$SCRIPT_PATH\" \"${new_arr[@]}\""
    echo $cmd
}

while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        download "$line"
    fi
done <"$DOWNLOADS_PATH"
