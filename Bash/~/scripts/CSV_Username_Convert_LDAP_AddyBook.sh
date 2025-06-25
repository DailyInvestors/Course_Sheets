#!/bin/bash

# ldap_report_generator.sh
# This script takes a CSV file of user data and generates a basic LDAP Data Interchange Format (LDIF) report.
#
# IMPORTANT SECURITY WARNINGS:
# 1. THIS SCRIPT IS FOR DEMONSTRATION AND EDUCATIONAL PURPOSES ONLY.
# 2. DO NOT USE IT WITH REAL, SENSITIVE PRODUCTION PASSWORDS IN PLAINTEXT.
#    LDAP passwords should always be hashed using strong, modern algorithms (e.g., bcrypt, Argon2).
#    This script uses SSHA for demonstration, which is NOT PRODUCTION SECURE.
# 3. THE GENERATED LDIF FILE CONTAINS SENSITIVE DATA. HANDLE WITH EXTREME CARE.

# --- Configuration ---
INPUT_CSV_FILE=""
OUTPUT_LDIF_FILE="ldap_report_$(date +%Y%m%d_%H%M%S).ldif"

# --- LDAP Base DN Configuration ---
# Customize these to match your LDAP directory structure
LDAP_BASE_DN="dc=example,dc=com"
LDAP_USERS_OU="People" # Organizational Unit for users

# --- Password Hashing Function (SSHA - for DEMO ONLY) ---
# Function to generate a simple SSHA hash for LDIF.
# THIS IS NOT CRYPTOGRAPHICALLY SECURE FOR PRODUCTION PASSWORDS.
# It requires 'openssl'.
generate_ssha_hash() {
    local password="$1"
    # Generate a random salt (4 bytes, base64 encoded for SSHA)
    local salt=$(head /dev/urandom | tr -dc A-Za-z0-9+/= | head -c 4 | base64)
    # Use openssl to hash the password with the salt using SSHA
    local hash_output=$(echo -n "$password" | openssl passwd -stdin -salt "$salt" -ssha)
    echo "$hash_output"
}

# --- Usage Message ---
usage() {
    echo "Usage: $0 <input_csv_file>"
    echo "       The input CSV must have headers (which are skipped) and the following columns, in order:"
    echo "       username,first_name,last_name,phone_number,street_address,city,state,password"
    echo ""
    echo "Example: $0 users.csv"
    exit 1
}

# --- Main Script Logic ---

# Check for input file argument
if [[ -z "$1" ]]; then
    usage
fi

INPUT_CSV_FILE="$1"

# Check if input CSV file exists
if [[ ! -f "$INPUT_CSV_FILE" ]]; then
    echo "Error: Input CSV file '$INPUT_CSV_FILE' not found."
    exit 1
fi

echo "--- Generating LDAP Report ---"
echo "Input CSV: '$INPUT_CSV_FILE'"
echo "Output LDIF: '$OUTPUT_LDIF_FILE'"
echo "LDAP Base DN: '$LDAP_BASE_DN'"
echo "Users OU: '$LDAP_USERS_OU'"
echo ""
echo "!!! SECURITY WARNING: Passwords will be hashed using SSHA (DEMO ONLY). !!!"
echo "!!! This is NOT secure for production. Treat the LDIF file as highly sensitive. !!!"
echo ""

# Generate the LDIF report using Awk
# -F ',' sets the field separator to comma for CSV.
# NR > 1 skips the header line of the CSV.
# The `AWK_SCRIPT` constructs each LDIF entry.
awk -v base_dn="$LDAP_BASE_DN" -v users_ou="$LDAP_USERS_OU" '
BEGIN {
    FS="," # Set field separator to comma for CSV
    # Print LDIF header
    print "version: 1"
    print "dn: ou=" users_ou "," base_dn
    print "objectClass: organizationalUnit"
    print "objectClass: top"
    print "ou: " users_ou
    print "" # Blank line separates entries
}

NR > 1 { # Skip header row (NR==1)
    # CSV Columns: username,first_name,last_name,phone_number,street_address,city,state,password
    # Awk fields:  $1        $2         $3        $4           $5             $6   $7    $8

    username = $1
    first_name = $2
    last_name = $3
    phone_number = $4
    street_address = $5
    city = $6
    state = $7
    plaintext_password = $8

    # --- Generate DN (Distinguished Name) ---
    # Example: dn: uid=john.doe,ou=People,dc=example,dc=com
    print "dn: uid=" username "," "ou=" users_ou "," base_dn

    # --- Object Classes ---
    # These define the type of entry and its allowed attributes.
    print "objectClass: inetOrgPerson" # Common for people entries
    print "objectClass: posixAccount"  # Adds UID, GID, home directory, shell
    print "objectClass: top"

    # --- Required Attributes ---
    print "uid: " username
    print "cn: " first_name " " last_name  # Common Name
    print "sn: " last_name               # Surname
    print "givenName: " first_name      # Given Name

    # --- Password Handling (SSHA Hashed - DEMO ONLY) ---
    # In a real scenario, this 'generate_ssha_hash' would be an external command.
    # Awk cannot directly run shell functions in this manner across pipes efficiently.
    # For this demo, we'll shell out to 'generate_ssha_hash' for each line.
    # Note: THIS IS SLOW FOR LARGE FILES. Better to hash the entire column once if possible.
    # Or, for the purpose of this demo, use a placeholder.
    # For simplicity of this Awk script within Bash, we'll pass the plaintext to a Bash function.
    printf "userPassword: "
    system("generate_ssha_hash \"" plaintext_password "\"") # Call Bash function to hash

    # --- Optional Attributes ---
    if (phone_number != "") {
        print "telephoneNumber: " phone_number
    }

    # Addresses (postalAddress can be multi-line, each line prefixed with 'postalAddress: ')
    # For LDIF, multi-line values are base64 encoded, or escaped with \ (not ideal for address).
    # A simpler approach for general "address" is to combine them or use specific attributes.
    # Let's use postalAddress and separate components for a basic demo.
    if (street_address != "") {
        print "street: " street_address
        # postalAddress can combine all address components or be just a street address
        # For multi-line in LDIF, it requires base64 encoding if it contains newlines.
        # For simplicity, we'll put it on one line.
        print "postalAddress: " street_address "$" city "$" state
    }
    if (city != "") {
        print "l: " city # Locality
    }
    if (state != "") {
        print "st: " state # State or Province
    }

    # --- Posix Account Specifics (Common Defaults) ---
    # In a real system, uidNumber and gidNumber would be managed by LDAP or an ID management system.
    # For a report, we can assign sequential or default values.
    # Let's use NR (line number) for unique UID, and a default GID.
    print "uidNumber: " (NR + 1000) # Start UIDs from 1001
    print "gidNumber: 1000"         # Default GID for 'users' group
    print "homeDirectory: /home/" username
    print "loginShell: /bin/bash"

    print "" # Blank line to separate entries in LDIF
}

END {
    print ""
    print "Status: LDIF generation complete."
}
' "$INPUT_CSV_FILE" > "$OUTPUT_LDIF_FILE"

# Re-enable the generate_ssha_hash function call within Awk by running this script in bash
# NOTE: This approach of calling bash function from awk using 'system()' for each line is
# inefficient for very large files. For large datasets, you'd pre-process passwords or
# use a dedicated LDIF generation tool.

echo "LDAP report saved to '$OUTPUT_LDIF_FILE'"
echo "You can view the report using: less '$OUTPUT_LDIF_FILE'"
echo "To import this into an LDAP server (DANGEROUS without proper setup):"
echo "  ldapadd -x -D 'cn=admin,dc=example,dc=com' -w 'your_admin_password' -f '$OUTPUT_LDIF_FILE'"
echo "REMEMBER TO SECURELY DELETE THE LDIF FILE AFTER USE."

