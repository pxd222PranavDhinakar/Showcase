#!/bin/bash

MATCHES=$(cat -)
SIZE_FILTER="$1"
TYPE_FILTER="$2"
MODIFIED_FILTER="$3"
OWNER_FILTER="$4"
PERMISSIONS_FILTER="$5"
EXCLUDE_PATTERN="$6"

# If no filtering criteria provided, return the original matches
if [[ -z "$SIZE_FILTER" && -z "$TYPE_FILTER" && -z "$MODIFIED_FILTER" && -z "$OWNER_FILTER" && -z "$PERMISSIONS_FILTER" && -z "$EXCLUDE_PATTERN" ]]; then
    echo "$MATCHES"
    exit 0
fi

# Filter by file size
if [[ -n "$SIZE_FILTER" ]]; then
    MATCHES=$(echo "$MATCHES" | xargs stat -c '%s %n' 2>/dev/null | awk "\$1 $SIZE_FILTER" | cut -d' ' -f2-)
fi

# Filter by file type
if [[ -n "$TYPE_FILTER" ]]; then
    MATCHES=$(echo "$MATCHES" | while read -r line; do
        if [[ "${line##*.}" == "$TYPE_FILTER" ]]; then
            echo "$line"
        fi
    done)
fi

# Filter by modification time
if [[ -n "$MODIFIED_FILTER" ]]; then
    MATCHES=$(echo "$MATCHES" | xargs find -type f -mtime "$MODIFIED_FILTER" 2>/dev/null)
fi

# Filter by owner
if [[ -n "$OWNER_FILTER" ]]; then
    MATCHES=$(echo "$MATCHES" | xargs stat -c '%U %n' 2>/dev/null | grep -i "^$OWNER_FILTER" | cut -d' ' -f2-)
fi

# Filter by permissions
if [[ -n "$PERMISSIONS_FILTER" ]]; then
    MATCHES=$(echo "$MATCHES" | xargs stat -c '%A %n' 2>/dev/null | grep "^$PERMISSIONS_FILTER" | cut -d' ' -f2-)
fi

# Exclude files/directories
if [[ -n "$EXCLUDE_PATTERN" ]]; then
    MATCHES=$(echo "$MATCHES" | grep -iv "$EXCLUDE_PATTERN")
fi

# Output the filtered matches
echo "$MATCHES"