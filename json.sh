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

  value=$(jq -r .$key "$json_file")

  if [ "$value" = "null" ]; then
    value=""
  elif [[ "$value" == \[* ]]; then
    value=$(jq -r .$key[] "$json_file")
  fi

  echo $value
}
