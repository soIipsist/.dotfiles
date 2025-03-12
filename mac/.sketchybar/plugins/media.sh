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

# store current application as an environment variable
if [ -n "$APPLICATION" ]; then
    echo "$APPLICATION" >/tmp/sketchybar_app.txt
fi
