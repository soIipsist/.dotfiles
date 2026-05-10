SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SECRET_FILE="$SCRIPT_DIR/.secret_aliases"

if [ ! -f "$SECRET_FILE" ]; then
    touch "$SECRET_FILE"
fi

echo "Enter environment variables in KEY=VALUE format."
echo "Type 'exit' or press Enter on an empty line to finish."

while true; do
    read -rp "> " input

    if [[ -z "$input" || "$input" == "exit" || "$input" == "quit" ]]; then
        break
    fi

    if [[ "$input" =~ ^[A-Za-z_][A-Za-z0-9_]*=.*$ ]]; then
        echo "export $input" >>"$SECRET_FILE"
        echo "Saved: $input"
    else
        echo "Invalid format. Use KEY=VALUE"
    fi
done

echo "Variables saved to $SECRET_FILE"
