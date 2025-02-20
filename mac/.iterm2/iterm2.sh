# Function to convert hex to iTerm's float format (0.0 - 1.0)
hex_to_float() {
    printf "%.5f" "$(echo "ibase=16; scale=5; $(echo "$1" | tr 'a-f' 'A-F' | sed 's/\(..\)/0x\1 /g' | awk '{print $1/255}')" | bc)"
}

source "$dotfiles_directory/.config/colors/colors.sh"

if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

if [ -z "$ITERM2_PROFILE_NAME" ]; then
    ITERM2_PROFILE_NAME="main"
fi
ITERM2_PROFILE_NAME="main"

MAIN_PLIST="com.googlecode.iterm2.plist"
COLORS_PLIST="main.itermcolors"

destination_directory="$dotfiles_directory/.config/iterm2"

# Append to com.googlecode.iterm2.plist

cat <<EOF >"$MAIN_PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Custom Color Presets</key>
    <dict>
        <key>$ITERM2_PROFILE_NAME</key>
        <dict>
EOF

cat <<EOF >"$COLORS_PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
EOF

COLOR_KEYS=(
    ITERM2_FOREGROUND
    ITERM2_BACKGROUND
    ITERM2_BOLD_COLOR
    ITERM2_SELECTION_COLOR
    ITERM2_SELECTED_TEXT_COLOR
    ITERM2_LINK_COLOR
    ITERM2_CURSOR_COLOR
    ITERM2_CURSOR_GUIDE_COLOR
    ITERM2_BADGE_COLOR

    # ANSI 16 Colors
    ITERM2_ANSI_BLACK
    ITERM2_ANSI_RED
    ITERM2_ANSI_GREEN
    ITERM2_ANSI_YELLOW
    ITERM2_ANSI_BLUE
    ITERM2_ANSI_MAGENTA
    ITERM2_ANSI_CYAN
    ITERM2_ANSI_WHITE
    ITERM2_ANSI_BRIGHT_BLACK
    ITERM2_ANSI_BRIGHT_RED
    ITERM2_ANSI_BRIGHT_GREEN
    ITERM2_ANSI_BRIGHT_YELLOW
    ITERM2_ANSI_BRIGHT_BLUE
    ITERM2_ANSI_BRIGHT_MAGENTA
    ITERM2_ANSI_BRIGHT_CYAN
    ITERM2_ANSI_BRIGHT_WHITE

    # Additional UI Colors
    ITERM2_SMART_CURSOR_COLOR
    ITERM2_TAB_COLOR
    ITERM2_MARK_COLOR
    ITERM2_HIGHLIGHT_COLOR
)

# Read colors from JSON and write to plist
for key in "${COLOR_KEYS[@]}"; do
    hex_color=$(eval echo "\$$key")

    [ "$hex_color" = "null" ] && continue

    echo "$key - $hex_color"
    r=$(hex_to_float "${hex_color:1:3}")
    g=$(hex_to_float "${hex_color:3:5}")
    b=$(hex_to_float "${hex_color:5:7}")

    case $key in
    ITERM2_FOREGROUND) color_name="Foreground Color" ;;
    ITERM2_BACKGROUND) color_name="Background Color" ;;
    ITERM2_SELECTION_COLOR) color_name="Selection Color" ;;
    ITERM2_SELECTED_TEXT_COLOR) color_name="Selected Text Color" ;;
    ITERM2_LINK_COLOR) color_name="Link Color" ;;
    ITERM2_CURSOR_COLOR) color_name="Cursor Color" ;;
    ITERM2_CURSOR_TEXT_COLOR) color_name="Cursor Text Color" ;;
    ITERM2_CURSOR_GUIDE_COLOR) color_name="Cursor Guide Color" ;;
    ITERM2_BADGE_COLOR) color_name="Badge Color" ;;
    ITERM2_BOLD_COLOR) color_name="Bold Color" ;;
    ITERM2_ANSI_BLACK) color_name="Ansi 0 Color" ;;
    ITERM2_ANSI_RED) color_name="Ansi 1 Color" ;;
    ITERM2_ANSI_GREEN) color_name="Ansi 2 Color" ;;
    ITERM2_ANSI_YELLOW) color_name="Ansi 3 Color" ;;
    ITERM2_ANSI_BLUE) color_name="Ansi 4 Color" ;;
    ITERM2_ANSI_MAGENTA) color_name="Ansi 5 Color" ;;
    ITERM2_ANSI_CYAN) color_name="Ansi 6 Color" ;;
    ITERM2_ANSI_WHITE) color_name="Ansi 7 Color" ;;
    ITERM2_ANSI_BRIGHT_BLACK) color_name="Ansi 8 Color" ;;
    ITERM2_ANSI_BRIGHT_RED) color_name="Ansi 9 Color" ;;
    ITERM2_ANSI_BRIGHT_GREEN) color_name="Ansi 10 Color" ;;
    ITERM2_ANSI_BRIGHT_YELLOW) color_name="Ansi 11 Color" ;;
    ITERM2_ANSI_BRIGHT_BLUE) color_name="Ansi 12 Color" ;;
    ITERM2_ANSI_BRIGHT_MAGENTA) color_name="Ansi 13 Color" ;;
    ITERM2_ANSI_BRIGHT_CYAN) color_name="Ansi 14 Color" ;;
    ITERM2_ANSI_BRIGHT_WHITE) color_name="Ansi 15 Color" ;;
    ITERM2_SMART_CURSOR_COLOR) color_name="Smart Cursor Color" ;;
    ITERM2_TAB_COLOR) color_name="Tab Color" ;;
    ITERM2_MARK_COLOR) color_name="Mark Color" ;;
    ITERM2_HIGHLIGHT_COLOR) color_name="Highlight Color" ;;
    esac

    cat <<EOF >>"$MAIN_PLIST"
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
    cat <<EOF >>"$COLORS_PLIST"
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
cat <<EOF >>"$MAIN_PLIST"
        </dict>
    </dict>
</dict>
</plist>
EOF

cat <<EOF >>"$COLORS_PLIST"
</dict>
</plist>
EOF

echo "Conversion complete: $MAIN_PLIST"

defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$destination_directory"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
killall iTerm2
