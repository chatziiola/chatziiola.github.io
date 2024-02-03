#!/bin/bash

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq not found. Please install jq before running this script."
    exit 1
fi


# Function to remove the prefix / avoiding sed
# Example usage:
# get_data "TITLE" "FILE"
get_data() {
    local type="$1"
    local file="$2"
    grep -E "^#\+$type:" "$file" | head -n 1| sed -e  "s/^#+$type:[[:space:]]*//" -e 's/[[:space:]]*$//'
}


# Function to process org files and extract information
process_org_file() {
    local file="$1"
    local title=$(get_data "TITLE" $file)
    local description=$(get_data "DESCRIPTION" $file)
    local date=$(get_data "DATE" $file)
    local filetags=$(get_data "FILETAGS" $file)

    # Create JSON entry
    echo -e "{ \"filepath\": \"$file\", \n\"title\": \"$title\",\n \"description\": \"$description\",\n \"filetags\": \"$filetags\",\n \"date\": \"$date\"\n }"
}

# Recursive function to process directories
process_directory() {
    # Process each org file in the directory
    for file in $(find $1 -name '*.org'); do
        [ -e "$file" ] || continue  # Skip if no files found
        process_org_file "$file"
    done


}

# Check if directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory> <outputfile>"
    exit 1
fi

directory="$1"

# Check if the provided directory exists
if [ ! -d "$directory" ]; then
    echo "Error: Directory '$directory' not found."
    exit 1
fi

result_file="$2"

# Process the directory and print JSON entries
process_directory "$directory" | tee /tmp/myjson |  jq -s '.'  > $result_file 
python3 fixtags.py $result_file
