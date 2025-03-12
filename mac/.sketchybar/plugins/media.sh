#!/bin/bash

echo "$INFO" >/tmp/debug.txt

STATE="$(echo "$INFO" | jq -r '.state')"
MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"
APPLICATION="$(echo "$INFO" | jq -r '.app')"

if [ "$STATE" = "playing" ]; then
    sketchybar --set media label="$MEDIA"
elif [ "$STATE" = "paused" ]; then
    sketchybar --set media label="$MEDIA"
fi

# check if music is open
# APP_STATE="$(pgrep -x Music)"

# echo "$APP_STATE" >/tmp/debug.txt
# PLAYER_STATE=$(osascript -e "tell application \"Music\" to set playerState to (get player state) as text")
# if [[ $PLAYER_STATE == "stopped" ]]; then
#     sketchybar --set music drawing=off
#     exit 0
# fi

# title=$(osascript -e 'tell application "Music" to get name of current track')
# artist=$(osascript -e 'tell application "Music" to get artist of current track')

# store current application as an environment variable
if [ -n "$APPLICATION" ]; then
    echo "$APPLICATION" >/tmp/sketchybar_app.txt
fi
