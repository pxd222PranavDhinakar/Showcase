#!/bin/bash

# Directory path provided to the script (relative to current directory)
SEARCH_PATH="${1:-$DEFAULT_PATH}"

# Name pattern provided to the script (case-insensitive)
NAME_PATTERN="$2"

# File type provided to the script
FILE_TYPE="$3"

# Check if at least one of the parameters (name pattern or file type) is provided
if [[ -z "$NAME_PATTERN" && -z "$FILE_TYPE" ]]; then
    echo "Error: You must provide at least one parameter (name pattern or file type)."
    exit 1
fi

# Search for files
if [[ -n "$FILE_TYPE" ]]; then
    # Search for files with the specified file type
    FILE_MATCHES=$(find "$SEARCH_PATH" -type f -iname "*.$FILE_TYPE" 2>/dev/null)
else
    # Search for all files
    FILE_MATCHES=$(find "$SEARCH_PATH" -type f 2>/dev/null)
fi

# Filter files based on the name pattern
if [[ -n "$NAME_PATTERN" ]]; then
    MATCHES=$(echo "$FILE_MATCHES" | grep -i "$NAME_PATTERN" 2>/dev/null)
else
    MATCHES="$FILE_MATCHES"
fi

# Output the matches
echo "$MATCHES"