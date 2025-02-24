#!/bin/bash
source "../os.sh"
source "../dotfiles.sh"
source "../git.sh"
source "../json.sh"

hex2rgb() {
    # reset $1 to scrubbed hex: '#01efa9' becomes '01EFA9'
    set -- "$(echo "$1" | tr -d '#' | tr '[:lower:]' '[:upper:]')"
    START=0
    STR=
    while ((START < ${#1})); do
        # double each char under len 6 : FAB => FFAABB
        if ((${#1} < 6)); then
            STR="$(printf "${1:${START}:1}%.0s" 1 2)"
            ((START += 1))
        else
            STR="${1:${START}:2}"
            ((START += 2))
        fi
        echo "ibase=16; ${STR}" | bc
    done
    unset START STR
}
hex_color="#FF1481"
read r g b <<<$(hex2rgb "$hex_color")

r_float=$(echo "scale=10; $r / 255" | bc -l)
g_float=$(echo "scale=10; $g / 255" | bc -l)
b_float=$(echo "scale=10; $b / 255" | bc -l)

printf "%.8f" "$(echo $b_float)"

# echo "ibase=16; $(echo "$hex_color" | tr '[:lower:]' '[:upper:]')" | bc
