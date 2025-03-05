#!/bin/sh

source "$HOME/.config/themes/theme.sh"

DISK=$(df -lh | grep /dev/disk3s5 | awk '{print $5}')
BCOLOR=$COLOR_DEFAULT
COLOR=$COLOR_BACKGROUND

sketchybar --set $NAME icon="􀤂" \
	icon.color=$COLOR \
	background.color=$BCOLOR \
	label=" $DISK " \
	label.color=$COLOR
