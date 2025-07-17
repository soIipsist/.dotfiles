#!/bin/bash

SOURCE_DIR="$1"
DEST_DIR="$2"

if [ -z "$SOURCE_DIR" ]; then
    echo "Usage: $0 <source_directory> [destination_directory]"
    exit 1
fi

if [ -z "$DEST_DIR" ]; then
    DEST_DIR="$SOURCE_DIR"
fi

mkdir -p "$DEST_DIR"

shopt -s nullglob

for FILE in "$SOURCE_DIR"/*; do
    if [[ -f "$FILE" ]]; then

        YEAR=$(exiftool -s3 -DateTimeOriginal -d "%Y" "$FILE" 2>/dev/null)

        if [[ -z "$YEAR" ]]; then
            YEAR=$(date -r "$FILE" "+%Y")
        fi

        if [[ -z "$YEAR" ]]; then
            echo "Warning: Could not determine year for '$FILE'"
            continue
        fi

        TARGET_DIR="$DEST_DIR/$YEAR"
        mkdir -p "$TARGET_DIR"

        cp "$FILE" "$TARGET_DIR/"
        echo "Copied '$FILE' -> '$TARGET_DIR/'"
    fi
done
