source "../os.sh"

get_default_json_file() {

  os=$(get_os)
  json_file=$(pwd)/$os.json
  echo $json_file
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

extract_from_env() {
  value="$1"

  vars=$(echo "$value" | grep -o '\$\w\+' | sort -u)

  # Build list of variables that actually exist in the environment
  sub_vars=""
  for var in $vars; do
    env_variable=$(get_env_variable "$var")

    var_name="${var:1}"
    if [ -n "$env_variable" ]; then
      export "$var_name=$env_variable"
    fi

    # check if var_name is empty
    if [ -n "${!var_name}" ]; then
      value=$(echo "$value" | envsubst "$var")
    fi

  done

  echo "$value"
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

  env_value=$(extract_from_env "$value")

  if [ -n "$env_value" ]; then
    value="$env_value"
  fi

  echo "$value"
}

set_json_value() {
  key="$1"
  value="$2"
  json_file="$3"

  cat <<<$(jq --arg k "$key" --arg v "$value" '.[$k] = $v' "$json_file") >$json_file

}
