#!/bin/bash
APPLICATION=$(tail -n 1 /tmp/sketchybar_app.txt)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# echo "app: $APPLICATION" >/tmp/debug.txt
if [ -z "$MUSIC_OPTION" ]; then
    MUSIC_OPTION="ACTIVE_TAB"
fi

case "$MUSIC_OPTION" in
MUSIC*) chrome_script="$SCRIPT_DIR/chrome.scpt" ;;
ACTIVE*) chrome_script="$SCRIPT_DIR/chrome.scpt" ;;
*) chrome_script="$SCRIPT_DIR/chrome.scpt" ;;
esac

case "$APPLICATION" in
Google*) osascript "$chrome_script" ;;
null*) osascript $SCRIPT_DIR/music.scpt ;;
esac
