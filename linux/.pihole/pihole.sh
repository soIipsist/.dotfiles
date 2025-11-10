#!/bin/bash
DB="/etc/pihole/gravity.db"

add_group() {
    local name="$1"
    local desc="$2"

    if ! sudo sqlite3 "$DB" "SELECT name FROM 'group' WHERE name='$name';" | grep -q "$name"; then
        echo "[+] Creating group '$name'"
        sudo sqlite3 "$DB" "INSERT INTO 'group' (name, description, enabled) VALUES ('$name', '$desc', 1);"
    else
        echo "[=] Group '$name' already exists"
    fi
}

add_client_to_group() {
    local client="$1"
    local comment="$2"
    local groupname="$3"

    local group_id
    group_id=$(sudo sqlite3 "$DB" "SELECT id FROM 'group' WHERE name='$groupname';")
    if [ -z "$group_id" ]; then
        echo "[!] Group '$groupname' not found!"
        return 1
    fi

    local client_id
    client_id=$(sudo sqlite3 "$DB" "SELECT id FROM client WHERE ip='$client';")

    if [ -z "$client_id" ]; then
        echo "[+] Adding client '$client' ($comment)"
        sudo sqlite3 "$DB" "INSERT INTO client (ip, comment) VALUES ('$client', '$comment');"
        client_id=$(sudo sqlite3 "$DB" "SELECT id FROM client WHERE ip='$client';")
    else
        echo "[=] Client '$client' already exists"
    fi

    if ! sudo sqlite3 "$DB" "SELECT * FROM client_by_group WHERE group_id=$group_id AND client_id=$client_id;" | grep -q "$group_id"; then
        echo "[+] Linking '$client' → group '$groupname'"
        sudo sqlite3 "$DB" "INSERT INTO client_by_group (group_id, client_id) VALUES ($group_id, $client_id);"
    else
        echo "[=] Client '$client' already in group '$groupname'"
    fi
}

add_list() {
    local url="$1"
    local type="${2:-block}"

    if [ -z "$url" ]; then
        echo "[!] No URL or domain provided"
        return 1
    fi

    if [ "$type" = "block" ]; then
        if sudo sqlite3 "$DB" "SELECT address FROM adlist WHERE address='$url';" | grep -q "$url"; then
            echo "[=] Blocklist already exists: $url"
        else
            echo "[+] Adding blocklist: $url"
            sudo sqlite3 "$DB" "INSERT INTO adlist (address, enabled) VALUES ('$url', 1);"
            echo "[✓] Blocklist added and gravity updated"
        fi

    elif [ "$type" = "allow" ]; then
        if sudo sqlite3 "$DB" "SELECT address FROM adlist WHERE address='$url' AND type=1;" | grep -q "$url"; then
            echo "[=] Allowlist already exists: $url"
        else
            echo "[+] Adding allowlist: $url"
            sudo sqlite3 "$DB" "INSERT INTO adlist (type, address, enabled) VALUES (1, '$url', 1);"
            echo "[✓] Allowlist added and gravity updated"
        fi

    else
        echo "[!] Unknown type: $type. Use 'block' or 'allow'."
        return 1
    fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIHOLE_PORT=""

# copy all blocklists and add them
sudo cp -rf "$SCRIPT_DIR/blocklists" /etc/pihole
sudo cp -rf "$SCRIPT_DIR/allowlists" /etc/pihole

for file in "/etc/pihole/blocklists"/*; do
    url="file://$file"
    add_list $url
done

for file in "/etc/pihole/allowlists"/*; do
    url="file://$file"
    add_list $url
done

sudo chown -R pihole:pihole /etc/pihole/blocklists /etc/pihole/allowlists
sudo chmod -R a+r /etc/pihole/blocklists /etc/pihole/allowlists

# set default port (80 by default)
if [ -n "$PIHOLE_PORT" ]; then
    sudo pihole-FTL --config webserver.port "$PIHOLE_PORT"
fi

# create groups
echo ""
echo "=== Group Setup ==="
while true; do
    read -rp "Enter group name (or press Enter to finish): " groupname
    [[ -z "$groupname" ]] && break
    read -rp "Enter description for '$groupname': " groupdesc
    add_group "$groupname" "$groupdesc"
done

# create client and group association
echo ""
echo "=== Client Setup ==="
while true; do
    read -rp "Enter client IP or MAC (or press Enter to finish): " client
    [[ -z "$client" ]] && break
    read -rp "Enter comment for client '$client': " comment
    echo "Available groups:"
    sudo sqlite3 "$DB" "SELECT id, name FROM 'group';"
    read -rp "Enter group name to assign '$client' to: " groupname
    add_client_to_group "$client" "$comment" "$groupname"
done

echo "[+] Reloading Pi-hole..."
sudo pihole -g
echo "[✓] Configuration complete!"
