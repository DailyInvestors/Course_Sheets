#!/bin/bash

# txt2html.sh - A simple script to convert plain text to HTML.

# --- Configuration ---
HTML_TITLE="Converted Document" # Default title for the HTML page
CSS_STYLE="" # Add any inline CSS here, e.g., "body { font-family: sans-serif; }"

# --- Functions ---

# Function to display usage information
usage() {
  echo "Usage: $0 <input_file.txt> [output_file.html]"
  echo ""
  echo "Converts a plain text file to a basic HTML file."
  echo "If output_file.html is not provided, it will be derived from input_file.txt."
  echo ""
  echo "Options:"
  echo "  -t <title>   Set the HTML page title (default: \"$HTML_TITLE\")"
  echo "  -s <css>     Add inline CSS styles (e.g., \"body { font-family: monospace; }\")"
  echo "  -h           Display this help message"
  exit 1
}

# --- Main Script ---

# Parse command-line options
while getopts ":t:s:h" opt; do
  case $opt in
    t) HTML_TITLE="$OPTARG";;
    s) CSS_STYLE="$OPTARG";;
    h) usage;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage;;
  esac
done
shift $((OPTIND-1))

# Check for input file
if [ -z "$1" ]; then
  echo "Error: No input file specified."
  usage
fi

INPUT_FILE="$1"

if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: Input file '$INPUT_FILE' not found."
  exit 1
fi

# Determine output file name
if [ -z "$2" ]; then
  OUTPUT_FILE="${INPUT_FILE%.*}.html"
else
  OUTPUT_FILE="$2"
fi

# Start HTML output
echo "<!DOCTYPE html>" > "$OUTPUT_FILE"
echo "<html lang=\"en\">" >> "$OUTPUT_FILE"
echo "<head>" >> "$OUTPUT_FILE"
echo "  <meta charset=\"UTF-8\">" >> "$OUTPUT_FILE"
echo "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" >> "$OUTPUT_FILE"
echo "  <title>$HTML_TITLE</title>" >> "$OUTPUT_FILE"
if [ -n "$CSS_STYLE" ]; then
  echo "  <style>" >> "$OUTPUT_FILE"
  echo "    $CSS_STYLE" >> "$OUTPUT_FILE"
  echo "  </style>" >> "$OUTPUT_FILE"
fi
echo "</head>" >> "$OUTPUT_FILE"
echo "<body>" >> "$OUTPUT_FILE"
echo "  <pre>" >> "$OUTPUT_FILE" # Use <pre> for preformatted text to preserve whitespace

# Read input file line by line and escape HTML special characters
while IFS= read -r line; do
  # Escape &, <, > for HTML display
  line_escaped=$(echo "$line" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
  echo "$line_escaped" >> "$OUTPUT_FILE"
done < "$INPUT_FILE"

echo "  </pre>" >> "$OUTPUT_FILE"
echo "</body>" >> "$OUTPUT_FILE"
echo "</html>" >> "$OUTPUT_FILE"

echo "Successfully converted '$INPUT_FILE' to '$OUTPUT_FILE'."
