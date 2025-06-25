#!/bin/bash


# Function to escape special XML characters from a string.
# '&' -> '&amp;', '<' -> '&lt;', '>' -> '&gt;', '"' -> '&quot;', ''' -> '&apos;'
xml_escape() {
    local input="$1"
    # Use sed for multiple replacements
    echo "$input" | sed \
        -e 's/&/\&amp;/g' \
        -e 's/</\&lt;/g' \
        -e 's/>/\&gt;/g' \
        -e 's/"/\&quot;/g' \
        -e "s/'/\&apos;/g"
}

# Function to wrap each line of a multi-line string in <line> tags and escape content.
xml_wrap_lines() {
    local content="$1"
    # Read each line from the provided content, ensuring it's XML escaped
    while IFS= read -r line; do
        escaped_line=$(xml_escape "$line")
        echo "    <line>${escaped_line}</line>"
    done <<< "$content"
}

# --- Main Logic for Converting Content to XML ---

INPUT_SOURCE_TYPE="payload" # Default to payload (stdin)
INPUT_SOURCE_NAME="stdin"
INPUT_CONTENT=""

# Check if a file argument is provided
if [[ -n "$1" ]]; then
    INPUT_FILE="$1"
    if [[ ! -f "$INPUT_FILE" ]]; then
        echo "Error: File '$INPUT_FILE' not found." >&2
        exit 1
    fi
    INPUT_SOURCE_TYPE="file"
    INPUT_SOURCE_NAME=$(xml_escape "$INPUT_FILE")
    INPUT_CONTENT=$(cat "$INPUT_FILE")
else
    # No file argument, read from stdin (payload)
    # Check if stdin is from a pipe or direct input
    if ! test -t 0; then # test -t 0 returns true if stdin is a terminal (direct input)
        INPUT_SOURCE_NAME="pipe"
    fi
    INPUT_CONTENT=$(cat) # Read all from stdin
fi

# Get current timestamp in UTC
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Start the root XML element
echo "<content_report>"

# Add metadata about the source
echo "  <source type=\"${INPUT_SOURCE_TYPE}\" name=\"${INPUT_SOURCE_NAME}\"/>"
echo "  <timestamp>${timestamp}</timestamp>"

# Wrap the actual data content
echo "  <data>"
xml_wrap_lines "$INPUT_CONTENT"
echo "  </data>"

# End the root XML element
echo "</content_report>"
