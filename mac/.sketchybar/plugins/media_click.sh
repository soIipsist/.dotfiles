#!/bin/bash

source "$dotfiles_directory/.config/themes/theme.sh"

APPLICATION=$(tail -n 1 /tmp/sketchybar_app.txt)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$MUSIC_OPTION" in
FIRST*) chrome_script="$SCRIPT_DIR/chrome_first.scpt" ;;
ACTIVE*) chrome_script="$SCRIPT_DIR/chrome_active.scpt" ;;
*) chrome_script="$SCRIPT_DIR/chrome_music.scpt" ;;
esac

case "$APPLICATION" in
Google*) osascript "$chrome_script" ;;
null*) osascript $SCRIPT_DIR/music.scpt ;;
esac
