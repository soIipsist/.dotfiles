source "../os.sh"

get_default_json_file() {

  os=$(get_os)
  json_file=$(pwd)/$os.json
  echo $json_file
}

get_json_value() {
  key="$1"

  if [ -z $json_file ]; then
    json_file=$(get_default_json_file)
  fi

  if [ ! -f "$json_file" ]; then
    echo "Error: JSON file does not exist or is not readable."
    return 1
  fi

  value=$(jq -r .$key "$json_file")

  if [ "$?" -ne 0 ] || [ "$value" = "null" ]; then
    value=""
  elif [[ "$value" == \[* ]]; then
    value=$(jq -r .$key[] "$json_file")
  fi

  echo $value
}
