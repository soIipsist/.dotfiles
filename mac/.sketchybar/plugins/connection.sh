#!/bin/sh

source "$dotfiles_directory/.config/themes/theme.sh"

CONN=$(netstat | grep ESTABLISHED | wc -l | awk '{print $1}')

case $CONN in
3[0-9])
	BCOLOR=$COLOR_ORANGE_BRIGHT
	COLOR=$COLOR_BACKGROUND
	;;
2[0-9])
	BCOLOR=$COLOR_YELLOW_BRIGHT
	COLOR=$COLOR_BACKGROUND
	;;
[0-9] | 1[0-9])
	BCOLOR=$COLOR_DEFAULT
	COLOR=$COLOR_BACKGROUND
	;;
*)
	BCOLOR=$COLOR_RED_BRIGHT
	COLOR=$COLOR_BACKGROUND
	;;
esac

sketchybar --set conncount icon.color=$COLOR background.color=$BCOLOR label="request: $CONN " label.color=$COLOR
