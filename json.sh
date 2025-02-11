source "../os.sh"

get_default_json_file() {

  os=$(get_os)
  json_file=$(pwd)/$os.json
  echo $json_file
}

get_json_value() {

  key="$1"
  shift 1
  json_file="$1"
  shift 1
  default_value="$@"

  if [ -z $json_file ]; then
    json_file=$(get_default_json_file)
  fi

  if [ ! -f "$json_file" ]; then
    echo "Error: JSON file does not exist or is not readable."
    return 1
  fi

  value=$(jq -r .$key "$json_file")

  if [ "$?" -ne 0 ] || [ "$value" = "null" ]; then
    value="$default_value"
  elif [[ "$value" == \[* ]]; then
    value=$(jq -r .$key[] "$json_file")
  fi

  env_value=$(get_env_variable "$value")

  if [ ! -z "$env_value" ]; then
    value="$env_value"
  fi

  echo "$value"
}

get_env_variable() {
  ENV_FILE=".env"
  value="$1"

  # if value doesn't start with '$' then it's not an environment variable

  if [[ ! "$value" =~ ^\$.* ]]; then
    return 0
  fi

  value="${value#\$}"

  if [ -f "$ENV_FILE" ]; then

    env_value=$(grep -E "^$value=" "$ENV_FILE" | cut -d '=' -f2-)

    if [[ "$env_value" == *","* ]]; then # check if variable is an array
      IFS=',' read -r -a env_array <<<"$env_value"
      echo "${env_array[@]}"
    else
      echo "$env_value"
    fi
  fi
}

set_json_value() {
  key="$1"
  value="$2"
  json_file="$3"

  cat <<<$(jq --arg k "$key" --arg v "$value" '.[$k] = $v' "$json_file") >$json_file

}
