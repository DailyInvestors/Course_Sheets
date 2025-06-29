#!/bin/bash

# Script to calculate days until legal drinking age (21)

echo "Please enter your age: "
read age

if [[ "$age" -lt 21 ]]; then
    # Calculate years remaining, then convert to days
    years_remaining=$((21 - age))
    days_remaining=$((years_remaining * 365)) # Simple calculation, doesn't account for leap years fully
    echo "You are under 21. You have approximately $days_remaining days until you can legally drink alcohol."
else
    echo "You are $age years old. You are old enough to legally drink alcohol. Enjoy responsibly!"
fi
