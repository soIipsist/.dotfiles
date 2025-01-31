FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set space.$1 background.drawing=on
else
    sketchybar --set space.$1 background.drawing=off
fi
