#!/bin/bash

STATE="$(echo "$INFO" | jq -r '.state')"
MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"

if [ "$STATE" = "playing" ]; then
    sketchybar --set media label="$MEDIA" drawing=on icon="􀑪"
elif [ "$STATE" = "paused" ]; then
    sketchybar --set media label="$MEDIA" drawing=on icon="􀑪"
else
    sketchybar --set media label="" drawing=off icon=""
fi
