#!/bin/bash
APPLICATION=$(tail -n 1 /tmp/sketchybar_app.txt)
# echo "app: $APPLICATION" >/tmp/debug.txt

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$APPLICATION" in
Google*) osascript $SCRIPT_DIR/chrome.scpt ;;
*) ;;
esac
