 ☣️How to use this script☣️:
 ¹ Save the script:
   Save the code above into a file named mysystem.sh (or any other name you prefer).
   nano mysystem.sh

  ¹¹/² (Paste the code and save)

 ² Make it executable:
   chmod +x mysystem.sh

 ³ Run the script:
   ./mysystem.sh

Explanation of printf usage in the script:

  ☣️printf🐒

"format_string" [arguments]:
    %s: String argument.
 
   %-Ns: Left-justifies a string in a field of N characters.
 
   %Ns: Right-justifies a string in a field of N characters.
 
   %f: Floating-point number.
 
   %.Nf: Floating-point number with N decimal places.
  
  \n: Newline character.
  
  \t: Tab character.
  
  ANSI Escape Codes:
      \033[: Starts an escape sequence.
    
  0;31m: Sets foreground color to red (0 for reset/normal, 31 for red).
    
  0m: Resets all attributes (color, bold, etc.) to default.
    
  The script defines variables like RED, GREEN, NC (No Color) for easier use of these codes.
 🐒 Examples in the script:
   
 printf "${BLUE}%-20s %s\n": This formats a line with a blue color. It prints a string (%s) left-justified in a 20-character field, followed by another string (%s), and then a newline. This is used for "Key: Value" pairs.
  
  printf "${YELLOW}%-20s %10s %10s %10s %10s %s\n": Used for the table headers for disk usage. It defines specific widths and justifications for each column.
  
  printf "${GREEN}%-20s %10s %10s %10s %10s %s\n" $line: Used within the df loop to print each line of disk usage, ensuring the values align under the headers due to the matching format string.

This script provides a fast, way to instantly check a variety of endpoints on your System.

Requirements:
Must Have a Linux Terminal 
🎵 Most Systems automatically have BASH installed with or without your knowing. This is including Mobile Devices.



👁️system_info.sh👁️
Description: A Bash Code to help determine and understand your System.

Instructions:
1. Copy 
2. touch system_info.sh
3. Your choice of editor, open and paste, save.
4. Chmod 600
5. ./system_info.sh
This will work on almost every linux System. I tested it out on my phone. Works perfectly.
