#!/bin/bash

# local_recon.sh
# A short Bash script for local directory and user search on Linux/Unix systems.
#
# DISCLAIMER: FOR AUTHORIZED LOCAL SYSTEM AUDITING ONLY.
# DO NOT run on systems you do not have explicit permission to inspect.
#
# Usage:
#   1. Save the script: Save this content as 'local_recon.sh'.
#   2. Make executable: chmod +x local_recon.sh
#   3. Run: ./local_recon.sh
#
# Permissions:
#   Some commands might require 'sudo' or root privileges to access all information.
#   Run as a regular user first, then consider 'sudo ./local_recon.sh' if you need
#   more comprehensive results (e.g., for /root directory access).

# --- Configuration ---
OUTPUT_DIR="local_recon_results_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$OUTPUT_DIR/recon.log"
SUMMARY_FILE="$OUTPUT_DIR/summary.txt"

# --- Logging Function ---
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_section() {
    echo "" | tee -a "$LOG_FILE" "$SUMMARY_FILE"
    echo "--- $1 ---" | tee -a "$LOG_FILE" "$SUMMARY_FILE"
    echo "" | tee -a "$LOG_FILE" "$SUMMARY_FILE"
}

# --- Main Script ---

mkdir -p "$OUTPUT_DIR" || { echo "Error: Could not create output directory '$OUTPUT_DIR'. Exiting."; exit 1; }
echo "Local reconnaissance started. Results in '$OUTPUT_DIR'."
echo "Log file: '$LOG_FILE'"
echo "Summary file: '$SUMMARY_FILE'"

# --- 1. Identify Common User Directories ---
log_section "Common User Directories"
echo "Searching for common user home directories (might require sudo for /root):" | tee -a "$SUMMARY_FILE"
find /home -maxdepth 2 -type d -name ".*" 2>/dev/null | grep -v "/home/\./" | tee -a "$LOG_FILE" "$SUMMARY_FILE" # Hidden dirs
find /home -maxdepth 2 -type d ! -name ".*" -print 2>/dev/null | tee -a "$LOG_FILE" "$SUMMARY_FILE" # Visible dirs
if [ -d "/root" ] && [ "$(id -u)" -eq 0 ]; then # Check if /root exists and if running as root
    echo "/root directory content (first 10 items):" | tee -a "$SUMMARY_FILE"
    ls -la /root | head -n 10 | tee -a "$LOG_FILE" "$SUMMARY_FILE"
elif [ -d "/root" ]; then
    echo "/root directory exists, but access denied (run with sudo for more info)." | tee -a "$SUMMARY_FILE"
fi

# --- 2. Enumerate Local User Accounts ---
log_section "Local User Accounts"
echo "Users from /etc/passwd (excluding system accounts with shell /sbin/nologin or /bin/false):" | tee -a "$SUMMARY_FILE"
grep -E '^(?!#).*:[x*]:[0-9]{4,}:[0-9]{4,}:.*:(/home|/root)/.*:(/bin/bash|/bin/sh|/bin/zsh|/usr/bin/zsh|/bin/ksh)$' /etc/passwd | \
    awk -F: '{print "  Username: " $1 ", UID: " $3 ", GID: " $4 ", Home: " $6 ", Shell: " $7}' | tee -a "$LOG_FILE" "$SUMMARY_FILE"

echo "" | tee -a "$SUMMARY_FILE"
echo "All local user accounts with active shells (from /etc/passwd):" | tee -a "$SUMMARY_FILE"
# Extract usernames from /etc/passwd for accounts that have a valid shell
awk -F: '($7 != "/sbin/nologin" && $7 != "/bin/false" && $7 != "/usr/sbin/nologin") { print "  " $1 }' /etc/passwd | sort | tee -a "$LOG_FILE" "$SUMMARY_FILE"

# --- 3. Check for Common Admin/Root-Level Groups ---
log_section "Admin/Privileged Groups"
echo "Users in 'sudo' group (or equivalent):" | tee -a "$SUMMARY_FILE"
if grep -q '^sudo:' /etc/group; then
    grep '^sudo:' /etc/group | awk -F: '{print "  sudo group members: " $4}' | tee -a "$LOG_FILE" "$SUMMARY_FILE"
fi

echo "Users in 'wheel' group (common on RHEL/CentOS for sudo):" | tee -a "$SUMMARY_FILE"
if grep -q '^wheel:' /etc/group; then
    grep '^wheel:' /etc/group | awk -F: '{print "  wheel group members: " $4}' | tee -a "$LOG_FILE" "$SUMMARY_FILE"
fi

echo "Users with UID 0 (root equivalent):" | tee -a "$SUMMARY_FILE"
grep -E '^[^:]*:[^:]*:0:' /etc/passwd | awk -F: '{print "  " $1}' | tee -a "$LOG_FILE" "$SUMMARY_FILE"

log "Local reconnaissance completed. Check '$OUTPUT_DIR' for full details."
echo ""
echo "Summary report: '$SUMMARY_FILE'"
echo "Detailed log:   '$LOG_FILE'"
