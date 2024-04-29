#!/bin/bash

MATCHES=$(cat -)
OUTPUT_FORMAT="${1:-$DEFAULT_FORMAT}"
SORT_CRITERIA="${2:-$DEFAULT_SORT}"

# Sort the matches based on the specified criteria
case "$SORT_CRITERIA" in
    name)
        SORTED_MATCHES=$(echo "$MATCHES" | sort)
        ;;
    size)
        SORTED_MATCHES=$(echo "$MATCHES" | xargs ls -lS | awk '{print $9}')
        ;;
    time)
        SORTED_MATCHES=$(echo "$MATCHES" | xargs ls -ltr | awk '{print $9}')
        ;;
    *)
        SORTED_MATCHES="$MATCHES"
        ;;
esac

# Format the output based on the specified format
case "$OUTPUT_FORMAT" in
    long)
        echo "Files:"
        echo "----------------------------------------"
        echo "$SORTED_MATCHES" | xargs ls -lh
        ;;
    csv)
        echo "$SORTED_MATCHES" | tr '\n' ',' | sed 's/,$//'
        ;;
    json)
        FILES=$(echo "$SORTED_MATCHES" | tr '\n' ',' | sed 's/,$//')
        echo "[\"${FILES//,/\",\"}\"]"
        ;;
    *)
        echo "$SORTED_MATCHES"
        ;;
esac