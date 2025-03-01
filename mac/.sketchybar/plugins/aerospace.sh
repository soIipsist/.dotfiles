FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
APP_NAME=$(aerospace list-windows --workspace focused --format %{app-name} | tail -n1)

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set space.$1 background.drawing=on
    sketchybar --set active_workspace label="$APP_NAME"
else
    sketchybar --set space.$1 background.drawing=off
fi
