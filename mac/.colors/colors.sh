export_variables_from_json() {

    json_file="$1"

    if [ -z "$json_file" ]; then
        json_file="$HOME/.config/colors/colors_1.json"
    fi

    while IFS='=' read -r key value; do
        export "$key"="$value"
    done < <(jq -r 'to_entries | .[] | "\(.key)=\(.value)"' "$json_file")

}

destination_directory="$dotfiles_directory/.config/colors"
echo $destination_directory
