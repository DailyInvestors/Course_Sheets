#!/bin/bash

# rectangle_surface_area.sh
# This script calculates the surface area of a rectangle based on
# two integer values provided as its length and width.

# --- Configuration: Assigning the dimensions of the rectangle ---
# It's good practice to assign values at the beginning of the script
# for easy modification.

# Variable for the length of the rectangle (e.g., in units like cm, inches, meters)
# Let's set it to an integer value.
LENGTH=15

# Variable for the width of the rectangle (must be the same unit as length)
# Let's set it to another integer value.
WIDTH=8

# --- Calculation: Compute the surface area ---
# Bash can perform arithmetic operations using $((...)) syntax.
# The result of the multiplication will be stored in the 'AREA' variable.
AREA=$((LENGTH * WIDTH))

# --- Output: Display the results elegantly ---
# We'll use 'echo' and 'printf' for clear and formatted output.
# 'printf' offers more control over formatting, similar to C's printf.

echo "" # Adds an empty line for better visual separation

echo "--- Rectangle Surface Area Calculator ---"
echo "---------------------------------------"

echo "Dimensions of the Rectangle:"
echo "  Length: $LENGTH units" # Displays the assigned length
echo "  Width:  $WIDTH units"  # Displays the assigned assigned width
echo ""

# Displaying the calculated area.
# We'll emphasize the result with a decorative border.
echo "---------------------------------------"
printf "| The calculated surface area is: %-4s square units |\n" "$AREA"
echo "---------------------------------------"

echo "" # Adds another empty line at the end

# --- Script End ---
