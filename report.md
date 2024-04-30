# Directory Structure

```
Scripts/
|-- asm_analysis.awk
|-- file-management-system/
|   |-- batch/
|   |   +-- batch_processing.sh
|   |-- config/
|   |   +-- batch_config.txt
|   |-- interactive/
|   |   |-- interactive_mode.sh
|   |   +-- test.txt
|   |-- output/
|   |   +-- output_formatter.sh
|   |-- search/
|   |   |-- file_filter.sh
|   |   +-- file_search.sh
|   +-- utils/
|   |   +-- file_metadata.sh
|-- generate_report.sh
+-- monitor_resources.sh
```

# Script Contents

## generate_report.sh
```bash
#!/bin/bash

# Function to process each file
process_file() {
    local file="$1"
    local relative_path="${file#$working_directory/}"

    echo "## $relative_path" >> "$report_file"
    echo "\\`\\`\\`bash" >> "$report_file"
    
    # Escape backticks and triple backticks in the file content
    sed 's/\`/\\\`/g; s/\`\`\`/\\\`\`\`/g' "$file" >> "$report_file"
    
    echo "" >> "$report_file"  # Add a newline before the ending backticks
    echo "\\`\\`\\`" >> "$report_file"
    echo "" >> "$report_file"
}

# Function to recursively process directories and generate the directory structure
process_directory() {
    local directory="$1"
    local indent="$2"
    local is_root="$3"

    if [ "$is_root" = true ]; then
        echo "${directory##*/}/" >> "$report_file"
    fi

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
            process_directory "$entry" "$indent|   " false
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
echo "\\`\\`\\`" >> "$report_file"
process_directory "$working_directory" "" true >> "$report_file"
echo "\\`\\`\\`" >> "$report_file"
echo "" >> "$report_file"

# Output the script contents
echo "# Script Contents" >> "$report_file"
echo "" >> "$report_file"
find "$working_directory" -type f | while read -r file; do
    process_file "$file"
done
```

## monitor_resources.sh
```bash
#!/bin/bash

# Thresholds
cpu_threshold=75
mem_threshold=70
disk_threshold=80
network_threshold=1000  # KB/s

# Get CPU usage (macOS adjusted command)
cpu_usage=$(top -l 1 -s 0 -n 0 | awk '/CPU usage:/ {print $3}' | sed 's/%//')

# Get Memory usage (macOS adjusted method)
mem_total=$(sysctl hw.memsize | awk '{print $2}')
mem_free=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
# Converting pages to bytes (assuming page size is 4096 bytes)
mem_free_bytes=$(($mem_free * 4096))
mem_usage=$(echo "scale=2; (1 - $mem_free_bytes / $mem_total) * 100" | bc)

# Get Disk usage (should work on macOS as well)
disk_usage=$(df / | awk 'END{print $5}' | sed 's/%//')

# Network activity: simplified version, monitor data packets instead
network_in_packets=$(netstat -ib | awk '/en0/ && /Link#/{print $7}')  # Replace 'en0' with your network interface
network_out_packets=$(netstat -ib | awk '/en0/ && /Link#/{print $10}') # Replace 'en0' with your network interface

# Check and print alerts
echo "Resource Usage:"
echo "CPU Usage: $cpu_usage%"
echo "Memory Usage: $mem_usage%"
echo "Disk Usage: $disk_usage%"
echo "Network IN Packets: $network_in_packets"
echo "Network OUT Packets: $network_out_packets"

if (( $(echo "$cpu_usage > $cpu_threshold" | bc -l) )); then
  echo "Alert: CPU usage is above threshold."
fi
if (( $(echo "$mem_usage > $mem_threshold" | bc -l) )); then
  echo "Alert: Memory usage is above threshold."
fi
if (( $(echo "$disk_usage > $disk_threshold" | bc -l) )); then
  echo "Alert: Disk usage is above threshold."
fi
if [[ "$network_in_packets" -gt "$network_threshold" || "$network_out_packets" -gt "$network_threshold" ]]; then
  echo "Alert: Network activity is above threshold."
fi

```

## asm_analysis.awk
```bash
#!/usr/bin/awk -f

BEGIN {
    print "Assembly Code Analysis:\n"
}

/^[^;]/ {
    # Remove leading whitespace
    gsub(/^\s+/, "")

    # Extract the instruction and operands
    instruction = $1
    operands = $0
    sub(/^[^\t]+\t*/, "", operands)

    # Analyze the instruction
    if (instruction == ".cfi_startproc") {
        print "Start of the function prologue"
    } else if (instruction == "sub") {
        print "Subtract " operands " from the stack pointer (sp) to allocate stack space"
    } else if (instruction == ".cfi_def_cfa_offset") {
        print "Set the CFA (Canonical Frame Address) offset to " operands
    } else if (instruction == "stp") {
        print "Store a pair of registers " operands " onto the stack"
    } else if (instruction == "add") {
        print "Add " operands " to the destination register"
    } else if (instruction == ".cfi_def_cfa") {
        print "Define the CFA (Canonical Frame Address) register and offset"
    } else if (instruction == ".cfi_offset") {
        print "Set the offset of a register " operands " in the CFA"
    } else if (instruction == "mov") {
        print "Move the value " operands " to the destination register"
    } else if (instruction == "str") {
        print "Store the value from register " operands " to memory"
    } else if (instruction == "adrp") {
        print "Calculate the page address of a symbol " operands " and store it in the destination register"
    } else if (instruction == "add") {
        print "Add the page offset of a symbol " operands " to the destination register"
    } else if (instruction == "bl") {
        print "Branch with link to the function " operands
    } else if (instruction == "ldp") {
        print "Load a pair of registers " operands " from the stack"
    } else if (instruction == "ret") {
        print "Return from the function"
    } else if (instruction == ".loh") {
        print "Linker optimization hint: " operands
    } else if (instruction == ".cfi_endproc") {
        print "End of the function epilogue"
    } else {
        print "Unknown instruction: " $0
    }

    print ""
}

/^;/ {
    print "Comment: " $0 "\n"
}

END {
    print "End of Assembly Code Analysis"
}

/^\s*\.section/ {
    print "Directive: Specify the section for the following code or data: " $0
}

/^\s*\.build_version/, /^\s*\.sdk_version/ {
    print "Directive: Specify build and SDK version information: " $0
}

/^\s*\.globl/ {
    print "Directive: Declare a global symbol: " $0
}

/^\s*\.p2align/ {
    print "Directive: Align the following code or data on a power-of-two boundary: " $0
}

/^\s*[a-zA-Z0-9_]+:/ {
    print "Label: Define a label for addressability: " $0
}

# ... Add more rules for other directives and instructions
```

## file-management-system/config/batch_config.txt
```bash
name_pattern=test
content_pattern=
size_filter=
type_filter=txt
modified_filter=
owner_filter=
permissions_filter=
exclude_pattern=
output_format=long
sort_criteria=name
actions=copy

```

## file-management-system/output/output_formatter.sh
```bash
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
```

## file-management-system/utils/file_metadata.sh
```bash
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
```

## file-management-system/search/file_search.sh
```bash
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
```

## file-management-system/search/file_filter.sh
```bash
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
```

## file-management-system/batch/batch_processing.sh
```bash
#!/bin/bash

BATCH_CONFIG_FILE="$1"

# Read search criteria and actions from the config file
NAME_PATTERN=$(grep "^name_pattern=" "$BATCH_CONFIG_FILE" | cut -d'=' -f2)
CONTENT_PATTERN=$(grep "^content_pattern=" "$BATCH_CONFIG_FILE" | cut -d'=' -f2)
SIZE_FILTER=$(grep "^size_filter=" "$BATCH_CONFIG_FILE" | cut -d'=' -f2)
TYPE_FILTER=$(grep "^type_filter=" "$BATCH_CONFIG_FILE" | cut -d'=' -f2)
MODIFIED_FILTER=$(grep "^modified_filter=" "$BATCH_CONFIG_FILE" | cut -d'=' -f2)
OWNER_FILTER=$(grep "^owner_filter=" "$BATCH_CONFIG_FILE" | cut -d'=' -f2)
PERMISSIONS_FILTER=$(grep "^permissions_filter=" "$BATCH_CONFIG_FILE" | cut -d'=' -f2)
EXCLUDE_PATTERN=$(grep "^exclude_pattern=" "$BATCH_CONFIG_FILE" | cut -d'=' -f2)
OUTPUT_FORMAT=$(grep "^output_format=" "$BATCH_CONFIG_FILE" | cut -d'=' -f2)
SORT_CRITERIA=$(grep "^sort_criteria=" "$BATCH_CONFIG_FILE" | cut -d'=' -f2)
ACTIONS=$(grep "^actions=" "$BATCH_CONFIG_FILE" | cut -d'=' -f2)

# Perform search and filtering
INITIAL_RESULTS=$($FILE_SEARCH_SCRIPT "." "$NAME_PATTERN" "$CONTENT_PATTERN")
FILTERED_RESULTS=$($FILE_FILTER_SCRIPT "$INITIAL_RESULTS" "$SIZE_FILTER" "$TYPE_FILTER" "$MODIFIED_FILTER" "$OWNER_FILTER" "$PERMISSIONS_FILTER" "$EXCLUDE_PATTERN")

# Format and output results
$OUTPUT_FORMATTER_SCRIPT "$FILTERED_RESULTS" "$OUTPUT_FORMAT" "$SORT_CRITERIA"

# Perform actions on matched files
for ACTION in $ACTIONS; do
    case "$ACTION" in
        copy)
            echo "Copying matched files..."
            # Implement copy action logic here
            ;;
        move)
            echo "Moving matched files..."
            # Implement move action logic here
            ;;
        rename)
            echo "Renaming matched files..."
            # Implement rename action logic here
            ;;
        delete)
            echo "Deleting matched files..."
            # Implement delete action logic here
            ;;
        *)
            echo "Invalid action: $ACTION"
            ;;
    esac
done
```

## file-management-system/interactive/interactive_mode.sh
```bash
#!/bin/bash

# Define script directories
SEARCH_DIR="../search"
OUTPUT_DIR="../output"
INTERACTIVE_DIR="interactive"
BATCH_DIR="../batch"
CONFIG_DIR="../config"

# Define script paths
FILE_SEARCH_SCRIPT="$SEARCH_DIR/file_search.sh"
FILE_FILTER_SCRIPT="$SEARCH_DIR/file_filter.sh"
OUTPUT_FORMATTER_SCRIPT="$OUTPUT_DIR/output_formatter.sh"
INTERACTIVE_MODE_SCRIPT="$INTERACTIVE_DIR/interactive_mode.sh"
BATCH_PROCESSING_SCRIPT="$BATCH_DIR/batch_processing.sh"
BATCH_CONFIG_FILE="$CONFIG_DIR/batch_config.txt"

# Define default values
DEFAULT_PATH="."
DEFAULT_FORMAT="long"
DEFAULT_SORT="name"

echo "Interactive Mode"
echo "================"
echo "Welcome to the File Management Tool!"
echo "Enter the corresponding number for the command you want to execute."
echo "Type 'exit' to quit the interactive mode."

while true; do
    echo ""
    echo "Available Commands:"
    echo "1. Search"
    echo "2. Filter"
    echo "3. Format"
    echo "4. Sort"
    echo "5. Actions"
    echo ""

    read -p "Enter the command number: " command

    case $command in
        1)
            echo ""
            echo "Search Command"
            echo "--------------"
            echo "Search for files based on name pattern and file type."
            read -p "Enter the search path (default: current directory): " search_path
            read -p "Enter the name pattern (leave blank for all files): " name_pattern
            read -p "Enter the file type (e.g., txt, pdf): " file_type
            SEARCH_RESULTS=$($FILE_SEARCH_SCRIPT "${search_path:-$DEFAULT_PATH}" "$name_pattern" "$file_type")
            
            if [ -z "$SEARCH_RESULTS" ]; then
                echo "No files with .$file_type extension and name containing '$name_pattern' (case-insensitive) found in ${search_path:-$DEFAULT_PATH}."
            else
                echo "$SEARCH_RESULTS" | $OUTPUT_FORMATTER_SCRIPT "$DEFAULT_FORMAT" "$DEFAULT_SORT"
            fi
            ;;
        2)

            echo ""
            echo "Filter Command"
            echo "--------------"
            echo "Filter the search results based on various criteria."
            read -p "Enter the size filter (e.g., '+1M', '-10K', leave blank to skip): " size_filter
            read -p "Enter the file type filter (e.g., 'txt', 'pdf', leave blank to skip): " type_filter
            read -p "Enter the modification time filter (e.g., '-7', '+30', leave blank to skip): " modified_filter
            read -p "Enter the owner filter (leave blank to skip): " owner_filter
            read -p "Enter the permissions filter (e.g., '-rw-r--r--', leave blank to skip): " permissions_filter
            read -p "Enter the exclude pattern (leave blank to skip): " exclude_pattern

            FILTERED_RESULTS=$(echo "$SEARCH_RESULTS" | $FILE_FILTER_SCRIPT "$size_filter" "$type_filter" "$modified_filter" "$owner_filter" "$permissions_filter" "$exclude_pattern")

            if [ -n "$FILTERED_RESULTS" ]; then
                echo "$FILTERED_RESULTS" | $OUTPUT_FORMATTER_SCRIPT "$DEFAULT_FORMAT" "$DEFAULT_SORT"
            else
                echo "No files found after applying filters."
            fi
            ;;

        3)
            echo ""
            echo "Format Command"
            echo "--------------"
            echo "Format the filtered results for display."
            read -p "Enter the output format (long, csv, json, default: long): " output_format
            $OUTPUT_FORMATTER_SCRIPT "$FILTERED_RESULTS" "${output_format:-$DEFAULT_FORMAT}" "$SORT_CRITERIA"
            ;;
        4)
            echo ""
            echo "Sort Command"
            echo "------------"
            echo "Sort the filtered results based on a criteria."
            read -p "Enter the sort criteria (name, size, time, default: name): " sort_criteria
            $OUTPUT_FORMATTER_SCRIPT "$FILTERED_RESULTS" "$OUTPUT_FORMAT" "${sort_criteria:-$DEFAULT_SORT}"
            ;;

        5)
            echo ""
            echo "Actions Command"
            echo "---------------"
            echo "Perform actions on the filtered files."
            echo "Available actions:"
            echo "1. Copy"
            echo "2. Move"
            echo "3. Rename"
            echo "4. Delete"
            read -p "Enter the action number: " action_number

            case $action_number in
                1)
                    read -p "Enter the destination directory: " destination
                    # Implement the copy action logic here
                    ;;
                2)
                    read -p "Enter the destination directory: " destination
                    # Implement the move action logic here
                    ;;
                3)
                    read -p "Enter the new name pattern: " new_name
                    # Implement the rename action logic here
                    ;;
                4)
                    read -p "Are you sure you want to delete the filtered files? (y/n): " confirm
                    if [[ $confirm == "y" || $confirm == "Y" ]]; then
                        # Implement the delete action logic here
                        echo "Files deleted successfully."
                    else
                        echo "Delete action cancelled."
                    fi
                    ;;
                *)
                    echo "Invalid action number. Please try again."
                    ;;
            esac
            ;;
        exit)
            echo "Exiting interactive mode. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid command. Please enter a valid command number."
            ;;
    esac
done
```

## file-management-system/interactive/test.txt
```bash
This is a test file.
It contains some sample text.
We will use this file to test the interactive mode.
```

