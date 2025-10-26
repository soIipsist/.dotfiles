#!/bin/bash
source "$dotfiles_directory/.config/themes/theme.sh"

STATE="$(echo "$INFO" | jq -r '.state')"
MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"
APPLICATION="$(echo "$INFO" | jq -r '.app')"

sketchybar --set media label="$MEDIA" label.align=center icon.align=center label.font="$FONT_2" icon="􀊖" label="No tracks playing"

if [ "$STATE" = "playing" ]; then
    sketchybar --set media label="$MEDIA" icon="􀊖"

elif [ "$STATE" = "paused" ]; then
    sketchybar --set media label="$MEDIA" icon="􀊖"

# check if Music app is open
APP_MUSIC_STATE="$(pgrep -x Music)"

# if it's open, check the music player state and update
if [ -n "$APP_MUSIC_STATE" ]; then
    MUSIC_PLAYER_STATE=$(osascript -e "tell application \"Music\" to set playerState to (get player state) as text")

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
fi

# store current application as an environment variable
if [ -n "$APPLICATION" ]; then
    echo "$APPLICATION" >/tmp/sketchybar_app.txt
fi
