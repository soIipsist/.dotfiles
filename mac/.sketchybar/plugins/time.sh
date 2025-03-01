#!/bin/sh

source "$HOME/.config/colors/colors.sh"

HOUR=$(date '+%H')

case $HOUR in
0[5-9])
    ICON=$ICON_CLOCK
    BCOLOR=$COLOR_CYAN_BRIGHT
    COLOR=$COLOR_BACKGROUND
    ;;
[1][0-1])
    ICON=$ICON_CLOCK
    BCOLOR=$COLOR_BLUE_BRIGHT
    COLOR=$COLOR_BACKGROUND
    ;;
[1][2-6])
    ICON=$ICON_CLOCK
    BCOLOR=$COLOR_ORANGE_BRIGHT
    COLOR=$COLOR_BACKGROUND
    ;;
[1][7-8])
    ICON=$ICON_CLOCK
    BCOLOR=$COLOR_RED_BRIGHT
    COLOR=$COLOR_BACKGROUND
    ;;
[1][9-2][0])
    ICON=$ICON_CLOCK
    BCOLOR=$COLOR_BLACK
    COLOR=$COLOR_DEFAULT
    ;;
0[0-4])
    ICON=$ICON_CLOCK
    BCOLOR=$COLOR_BLACK
    COLOR=$COLOR_DEFAULT
    ;;
*)
    ICON=$ICON_CLOCK
    BCOLOR=$COLOR_DEFAULT
    COLOR=$COLOR_BACKGROUND
    ;;
esac

sketchybar --set $NAME label="$(date '+%I:%M %p')" background.color=$BCOLOR icon.color=$COLOR label.color=$COLOR
