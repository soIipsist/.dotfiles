export_variables() {

    json_file="$1"

    while IFS='=' read -r key value; do
        export "$key"="$value"
    done < <(jq -r 'to_entries | .[] | "\(.key)=\(.value)"' "$json_file")

}

copy_colors() {

    destination_directory="$dotfiles_directory/.config/colors"

    color_scheme="colors_1"
    json_file="$PWD/.colors/$color_scheme.json"

}
