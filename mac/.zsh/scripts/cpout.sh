function copy-last-command-output() {
    last_cmd=$(fc -ln -1 | tail -n 1 | tr -d '\n' | tr -cd '[:print:]')
    output=$(eval "$last_cmd")
    trimmed_output=$(printf "%s" "$output")
    echo "$trimmed_output" | pbcopy
    echo "Last command's output copied to clipboard."
    zle accept-line
}

copy-last-command-output
