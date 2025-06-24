Description:
A basic Bash code that converts any txt file into a HTML document. This converts the output of a normal text file, into a HTML page.

Requirements: 
1. Linux
2. Bash
3. Linux Default Tools

Activate:
1. Copy the file.
2. nano or touch a file.
3. Paste
4. Chmod +X file_name.txt


To Run:
1. Basic Conversion: 
./txt2html.sh my_document.txt

2. Specify Output
./txt2html.sh notes.txt output/notes.html

3. Title
./txt2html.sh report.txt -t "My Daily Report"

4. Add CSS
./txt2html.sh code.txt -s "body { background-color: #f0f0f0; font-family: monospace; }"

5. Help
./txt2html.sh -h


