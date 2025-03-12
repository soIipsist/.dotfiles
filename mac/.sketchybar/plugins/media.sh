#!/bin/bash

STATE="$(echo "$INFO" | jq -r '.state')"
MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"
APPLICATION="$(echo "$INFO" | jq -r '.app')"

if [ "$STATE" = "playing" ]; then
    sketchybar --set media label="$MEDIA" icon="􀊖"

elif [ "$STATE" = "paused" ]; then
    sketchybar --set media label="$MEDIA" icon="􀊖"
fi

# check if Music app is open
APP_MUSIC_STATE="$(pgrep -x Music)"

MUSIC_PLAYER_STATE=$(osascript -e "tell application \"Music\" to set playerState to (get player state) as text")

echo "$MUSIC_PLAYER_STATE" >/tmp/debug.txt

if [[ $MUSIC_PLAYER_STATE == "stopped" ]]; then
    sketchybar --set music drawing=off

elif [[ $MUSIC_PLAYER_STATE == "playing" ]]; then
    title=$(osascript -e 'tell application "Music" to get name of current track')
    artist=$(osascript -e 'tell application "Music" to get artist of current track')

    MEDIA="$title"

    if [[ -n "$artist" ]]; then
        MEDIA="$MEDIA - $artist"
    fi

    sketchybar --set media label="$MEDIA" icon="􀊖"
fi

# store current application as an environment variable
if [ -n "$APPLICATION" ]; then
    echo "$APPLICATION" >/tmp/sketchybar_app.txt
fi
