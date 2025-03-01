#!/bin/zsh

MEDIA_REGEX="Spotify|Music|VLC|QuickTime|IINA|YouTube"

CURRENT_MEDIA_APP=$(
    aerospace list-windows --workspace focused --format '%{app-name}' |
        grep -Ei "$MEDIA_REGEX" |
        head -n 1
)

if [[ -z "$CURRENT_MEDIA_APP" ]]; then
    CURRENT_MEDIA_APP="No media"
fi

sketchybar --set media label="$CURRENT_MEDIA_APP"
