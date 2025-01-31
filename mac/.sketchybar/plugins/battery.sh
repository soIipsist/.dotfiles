PERCENTAGE="$(pmset -g batt | grep -Eo '[0-9]+%' | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ -z "$PERCENTAGE" ]; then
    exit 0
fi

case "$PERCENTAGE" in
9[0-9] | 100)
    ICON="􀛨" # Full battery
    ;;
[6-8][0-9])
    ICON="􀺸" # 75% battery
    ;;
[3-5][0-9])
    ICON="􀺶" # 50% battery
    ;;
[1-2][0-9])
    ICON="􀛩" # Low battery
    ;;
*) ICON="􀛪" ;; # Critical battery
esac

if [ -n "$CHARGING" ]; then
    ICON="􀢋" # Charging icon
fi

sketchybar --set battery icon="$ICON" label="${PERCENTAGE}%"
