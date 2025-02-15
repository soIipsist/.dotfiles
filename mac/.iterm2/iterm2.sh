if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

JSON_FILE="colors.json"
PLIST_FILE="iterm_colors.plist"
PROFILE_NAME="MyCustomTheme" # Change this if needed

# Function to convert hex to iTerm's float format (0.0 - 1.0)
hex_to_float() {
    printf "%.5f" "$(echo "ibase=16; scale=5; $(echo "$1" | tr 'a-f' 'A-F' | sed 's/\(..\)/0x\1 /g' | awk '{print $1/255}')" | bc)"
}

# Generate plist
cat <<EOF >"$PLIST_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Custom Color Presets</key>
    <dict>
        <key>$PROFILE_NAME</key>
        <dict>
EOF

# Define color mapping
declare -A COLOR_KEYS=(
    ["ITERM2_FOREGROUND"]="Foreground Color"
    ["ITERM2_BACKGROUND"]="Background Color"
    ["ITERM2_ANSI_BLACK"]="Ansi 0 Color"
    ["ITERM2_ANSI_RED"]="Ansi 1 Color"
    ["ITERM2_ANSI_GREEN"]="Ansi 2 Color"
    ["ITERM2_ANSI_YELLOW"]="Ansi 3 Color"
    ["ITERM2_ANSI_BLUE"]="Ansi 4 Color"
    ["ITERM2_ANSI_MAGENTA"]="Ansi 5 Color"
    ["ITERM2_ANSI_CYAN"]="Ansi 6 Color"
    ["ITERM2_ANSI_WHITE"]="Ansi 7 Color"
)

# source colors
source "$dotfiles_directory/.config/colors/colors.sh"

# Read colors from JSON and write to plist
for key in "${!COLOR_KEYS[@]}"; do
    hex_color=$(key)

    if [[ "$hex_color" == "null" ]]; then
        continue # Skip missing keys
    fi

    r=$(hex_to_float "${hex_color:0:2}")
    g=$(hex_to_float "${hex_color:2:2}")
    b=$(hex_to_float "${hex_color:4:2}")

    cat <<EOF >>"$PLIST_FILE"
            <key>${COLOR_KEYS[$key]}</key>
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

# # import plist
# defaults import com.googlecode.iterm2 itermcolors.plist

# destination_directory="$dotfiles_directory/.config/iterm2/iterm2.sh"

# echo "$destination_directory"
