#!/bin/bash

# Function to get file size
get_file_size() {
    local FILE="$1"
    stat -c %s "$FILE"
}

# Function to get file type
get_file_type() {
    local FILE="$1"
    file "$FILE" | awk -F':' '{