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