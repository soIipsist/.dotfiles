source "../json.sh"

color_scheme="colors_1"
json_file="colors/$color_scheme.json"

while IFS='=' read -r key value; do
    export "$key"="$value"
done < <(jq -r 'to_entries | .[] | "\(.key)=\(.value)"' "$json_file")
