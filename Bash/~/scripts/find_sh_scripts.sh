#!/bin/bash

# This script lists all files ending with .sh

echo "Searching for .sh files in the current directory and its subdirectories:"
echo "-----------------------------------------------------"

# Find files ending with .sh and print their paths
find . -type f -name "*.sh"

echo "-----------------------------------------------------"
echo "Search complete."
