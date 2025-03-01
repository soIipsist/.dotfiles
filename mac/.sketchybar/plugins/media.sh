#!/bin/bash

STATE="$(echo "$INFO" | jq -r '.state')"
MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"

if [ "$STATE" = "playing" ]; then
    sketchybar --set "$NAME" label="$MEDIA" drawing=on icon="􀑪"
elif [ "$STATE" = "paused" ]; then
    sketchybar --set "$NAME" label="$MEDIA" drawing=on icon="􀑪"
else
    sketchybar --set "$NAME" label="" drawing=off icon=""
fi
