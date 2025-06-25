Requirements:
1. Linux
2. Bash
3. XMLLint

Directions:
1. Copy the File
2. Create a file
3. Paste Contents
4. Chmod 777
5. Below are the different Options for activation and conversions. Range from a normal file, to payloads, to custome Pretty Print.
  
   a) Converting a Text File to XML:
   First, create a sample text file:
   echo -e "This is line one.\nLine two with special chars: < & >" > my_sample.txt

   Then, run the script:
   ./content_to_xml.sh my_sample.txt > my_sample.xml

   View my_sample.xml:
   <content_report>
  <source type="file" name="my_sample.txt"/>
  <timestamp>2025-06-25T19:39:55Z</timestamp> <data>
    <line>This is line one.</line>
    <line>Line two with special chars: &lt; &amp; &gt;</line>
  </data>
</content_report>

   b) Converting Piped Input (Payload) to XML:
   cat /etc/os-release | ./content_to_xml.sh | xmllint --format -

   This will take the content of /etc/os-release, pipe it to content_to_xml.sh, and then pipe the resulting XML to xmllint for pretty-printing and validation.
   c) Converting Manual Input to XML:
   ./content_to_xml.sh

   (The script will wait for your input. Type some lines, then press Ctrl+D on a new line to signal End-Of-File.)
Explanation of Key Changes:
  Input Handling (if [[ -n "$1" ]]...else...):
    The script now checks if a command-line argument ($1) is provided.
    If $1 exists and is a readable file, it assumes you want to convert that file. It reads the file content into INPUT_CONTENT using cat "$INPUT_FILE".
    If no argument is provided, it assumes the input is coming from stdin (a pipe or direct user input). INPUT_CONTENT=$(cat) reads all data available on standard input until EOF (End-Of-File).
  Metadata (<source> and <timestamp>):
    A <source> element is added to specify if the content came from a file or a payload (stdin/pipe) and to include the original file name if applicable.
    A <timestamp> element records when the conversion was performed.
  INPUT_CONTENT Variable: This variable now holds the entire content of the file or payload, which is then passed to xml_wrap_lines to create the <line> elements within the <data> tag.
This script makes it versatile for converting any textual content into a standard XML structure, making it suitable for logging, data transfer, or integration with XML-aware tools.
