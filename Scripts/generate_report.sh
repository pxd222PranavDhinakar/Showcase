#!/bin/bash

# Function to process each file
process_file() {
    local file="$1"
    local relative_path="${file#$working_directory/}"

    echo "## $relative_path" >> "$report_file"
    echo "\`\`\`bash" >> "$report_file"
    
    # Escape backticks and triple backticks in the file content
    sed 's/`/\\`/g; s/```/\\```/g' "$file" >> "$report_file"
    
    echo "" >> "$report_file"  # Add a newline before the ending backticks
    echo "\`\`\`" >> "$report_file"
    echo "" >> "$report_file"
}

# Function to recursively process directories and generate the directory structure
process_directory() {
    local directory="$1"
    local indent="$2"

    local entries=("$directory"/*)
    local num_entries=${#entries[@]}
    local i=1

    for entry in "$directory"/*; do
        if [ -d "$entry" ]; then
            if [ $i -eq $num_entries ]; then
                echo "$indent+-- ${entry##*/}/" >> "$report_file"
            else
                echo "$indent|-- ${entry##*/}/" >> "$report_file"
            fi
            process_directory "$entry" "$indent|   "
        elif [ -f "$entry" ]; then
            if [ $i -eq $num_entries ]; then
                echo "$indent+-- ${entry##*/}" >> "$report_file"
            else
                echo "$indent|-- ${entry##*/}" >> "$report_file"
            fi
        fi
        ((i++))
    done
}

# Check if the directory path is provided as an argument
if [ $# -eq 0 ]; then
    echo "Please provide the directory path as an argument."
    exit 1
fi

# Set the working directory path from the argument
working_directory="$1"

# Set the report file path
report_file="$(dirname "$working_directory")/report.md"

# Output the directory structure
echo "# Directory Structure" > "$report_file"
echo "" >> "$report_file"
echo "\`\`\`" >> "$report_file"
process_directory "$working_directory" "" >> "$report_file"
echo "\`\`\`" >> "$report_file"
echo "" >> "$report_file"

# Output the script contents
echo "# Script Contents" >> "$report_file"
echo "" >> "$report_file"
find "$working_directory" -type f | while read -r file; do
    process_file "$file"
done