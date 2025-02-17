if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

JSON_FILE="colors.json"
PLIST_FILE="iterm_colors.plist"

# Function to convert hex to iTerm's float format (0.0 - 1.0)
hex_to_float() {
    printf "%.5f" "$(echo "ibase=16; scale=5; $(echo "$1" | tr 'a-f' 'A-F' | sed 's/\(..\)/0x\1 /g' | awk '{print $1/255}')" | bc)"
}

# source colors
source "$dotfiles_directory/.config/colors/colors.sh"

if [ -z "$ITERM2_PROFILE_NAME" ]; then
    ITERM2_PROFILE_NAME="Custom profile"
fi

# Generate plist
cat <<EOF >"$PLIST_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Custom Color Presets</key>
    <dict>
        <key>$ITERM2_PROFILE_NAME</key>
        <dict>
EOF

COLOR_KEYS=(
    ITERM2_FOREGROUND
    ITERM2_BACKGROUND
    ITERM2_SELECTION_COLOR
    ITERM2_SELECTED_COLOR
    ITERM2_ANSI_BLACK
    ITERM2_ANSI_RED
    ITERM2_ANSI_GREEN
    ITERM2_ANSI_YELLOW
    ITERM2_ANSI_BLUE
    ITERM2_ANSI_MAGENTA
    ITERM2_ANSI_CYAN
    ITERM2_ANSI_WHITE
)

# Read colors from JSON and write to plist
for key in "${COLOR_KEYS[@]}"; do
    hex_color="${!key}" # Indirect expansion to get the actual value

    [ "$hex_color" = "null" ] && continue

    echo "$key - $hex_color"
    r=$(hex_to_float "${hex_color:1:3}")
    g=$(hex_to_float "${hex_color:3:5}")
    b=$(hex_to_float "${hex_color:5:7}")

    case $key in
    ITERM2_FOREGROUND) color_name="Foreground Color" ;;
    ITERM2_BACKGROUND) color_name="Background Color" ;;
    ITERM2_ANSI_BLACK) color_name="Ansi 0 Color" ;;
    ITERM2_ANSI_RED) color_name="Ansi 1 Color" ;;
    ITERM2_ANSI_GREEN) color_name="Ansi 2 Color" ;;
    ITERM2_ANSI_YELLOW) color_name="Ansi 3 Color" ;;
    ITERM2_ANSI_BLUE) color_name="Ansi 4 Color" ;;
    ITERM2_ANSI_MAGENTA) color_name="Ansi 5 Color" ;;
    ITERM2_ANSI_CYAN) color_name="Ansi 6 Color" ;;
    ITERM2_ANSI_WHITE) color_name="Ansi 7 Color" ;;
    esac

    cat <<EOF >>"$PLIST_FILE"
            <key>$color_name</key>
            <dict>
                <key>Red Component</key>
                <real>$r</real>
                <key>Green Component</key>
                <real>$g</real>
                <key>Blue Component</key>
                <real>$b</real>
            </dict>
EOF

done

# Close plist
cat <<EOF >>"$PLIST_FILE"
        </dict>
    </dict>
</dict>
</plist>
EOF

echo "Conversion complete: $PLIST_FILE"

# import plist
defaults import com.googlecode.iterm2 iterm_colors.plist

cmd="tell application "iTerm2" to set color preset to "$PROFILE_NAME""
osascript -e $cmd
# destination_directory="$dotfiles_directory/.config/iterm2/iterm2.sh"

# echo "$destination_directory"
