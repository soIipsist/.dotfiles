#!/bin/bash

if [ -z "$DOWNLOADS_PATH" ]; then
    DOWNLOADS_PATH="$HOME/downloads.txt"
fi

LOG_FILE="/var/log/download_watcher.log"

# ensure files exist
if [ ! -f "$DOWNLOADS_PATH" ]; then
    touch $DOWNLOADS_PATH
fi

touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

while true; do
    inotifywait -e modify "$WATCH_FILE"
    echo "$(date): File changed - $WATCH_FILE" >>"$LOG_FILE"
done
