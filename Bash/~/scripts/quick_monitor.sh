#!/bin/bash

# system_monitor.sh
# A Bash/Awk script to demonstrate defining patterns and actions
# for common system events and log entries.
#
# This script is for educational purposes to show how Awk's pattern matching
# and action blocks work for system monitoring. It is NOT a production-ready
# monitoring solution.
#
# Usage: sudo bash system_monitor.sh (sudo is often needed for log files)

echo "### System Pattern & Action Monitor ###"
echo "---------------------------------------"
echo "Starting scan for predefined system patterns..."
echo ""

# --- Configuration for patterns and actions ---
# You can customize these variables or add more sections.

# Log file paths (adjust based on your Linux distribution)
AUTH_LOG="/var/log/auth.log" # Debian/Ubuntu
# AUTH_LOG="/var/log/secure" # CentOS/RHEL/Fedora

SYSLOG="/var/log/syslog" # Debian/Ubuntu
# SYSLOG="/var/log/messages" # CentOS/RHEL/Fedora

# --- Awk Script Definition ---
# This is a multi-line Awk script embedded directly in Bash using a 'here document'.
# It defines various patterns and the actions to take when they are matched.
# Awk processes its input line by line.

AWK_SCRIPT=$(cat <<'EOF'
BEGIN {
    # This block runs once before any input lines are processed.
    print "--- Awk Pattern Definitions & Actions ---"
    print "Status: Monitoring initialized."
    print "-----------------------------------------"
    failed_logins_count = 0
    new_sessions_count = 0
    kernel_errors_count = 0
    apache_high_cpu_processes = 0
    print_network_listeners = 0
}

# --- Pattern 1: Failed Login Attempts ---
# Pattern: Looks for "failed password" in authentication logs.
# Action: Increments a counter and prints a warning.
/failed password/ {
    failed_logins_count++
    print "ALERT: Possible brute-force attempt detected: " $0
    print "       Source IP: " $NF # Often the last field is the IP
    print "-----------------------------------------"
}

# --- Pattern 2: New User Sessions (Successful Logins) ---
# Pattern: Looks for "session opened" in authentication logs.
# Action: Increments a counter and logs the user and source.
/session opened for user/ {
    new_sessions_count++
    # Extract username (often the 6th field on such lines)
    username = $6
    # You might need more complex parsing for other log formats
    print "INFO: New user session opened: " $0
    print "      User: " username
    print "-----------------------------------------"
}

# --- Pattern 3: Kernel Errors/Warnings ---
# Pattern: Looks for "kernel:" followed by "error" or "warn" in system logs.
# Action: Increments a counter and prints the full log line.
/kernel:.*(error|warn)/ {
    kernel_errors_count++
    print "WARNING: Kernel issue detected: " $0
    print "-----------------------------------------"
}

# --- Pattern 4: High CPU Usage for 'apache2' process ---
# Pattern: This applies to 'ps aux' output. Assumes 'apache2' process name.
# Action: Checks if the 3rd field (CPU usage) is > 10.0 and prints a specific alert.
# Note: $11 is command name for ps aux
$11 ~ /apache2/ && $3 > 10.0 {
    apache_high_cpu_processes++
    print "PERF_ALERT: Apache2 process using high CPU (" $3 "%): " $0
    print "            PID: " $2 ", User: " $1
    print "-----------------------------------------"
}

# --- Pattern 5: Listening Network Ports (from ss -tulpn) ---
# Pattern: This processes output from 'ss -tulpn'.
#          Looks for lines containing "LISTEN" that are not the header.
# Action: Prints details of listening ports.
# Note: The 'if (NR==1 && /State/)' block is for skipping the header line.
/LISTEN/ && NR > 1 { # Skip header if it exists and contains "State"
    # This action is designed to show all listening ports.
    # We set a flag in BEGIN to only print this if network scan is active
    # (though in this example, it's always active).
    if (print_network_listeners == 0) {
        print "NETWORK_INFO: Currently listening ports (Process/PID):"
        print_network_listeners = 1 # Set flag so header only prints once
    }
    # For ss -tulpn output, relevant fields are often:
    # State Recv-Q Send-Q Local Address:Port Peer Address:Port Process_Info
    # The Process_Info field often looks like "users:(("sshd",pid=123,fd=3)))"
    # We can try to extract the PID and name from the last field.
    process_info = $NF # Last field
    gsub(/users:\(\(|"\)|,\S*\)\)\)/, "", process_info) # Clean up process info
    print "  Port: " $5 ", Proto: " $1 ", PID/Name: " process_info
    print "-----------------------------------------"
}


END {
    # This block runs once after all input lines have been processed.
    print "-----------------------------------------"
    print "Scan Summary:"
    print "  Failed Login Attempts: " failed_logins_count
    print "  New User Sessions:     " new_sessions_count
    print "  Kernel Errors/Warnings: " kernel_errors_count
    if (apache_high_cpu_processes > 0) {
        print "  High CPU Apache2 Processes: " apache_high_cpu_processes
    }
    if (print_network_listeners == 1) {
        print "  Network Listener scan complete. See above for details."
    } else {
        print "  No listening network ports found via current scan."
    }
    print "-----------------------------------------"
    print "Monitoring complete."
}
EOF
)

# --- Execute the Awk script with various system inputs ---

echo "--- Processing Authentication Logs ($AUTH_LOG) ---"
if [[ -f "$AUTH_LOG" ]]; then
    tail -n 100 "$AUTH_LOG" | awk "$AWK_SCRIPT"
else
    echo "Warning: Auth log file '$AUTH_LOG' not found or not readable. Skipping."
fi
echo ""

echo "--- Processing System Logs (dmesg output) ---"
dmesg | awk "$AWK_SCRIPT"
echo ""

echo "--- Processing Process List (ps aux) ---"
ps aux | awk "$AWK_SCRIPT"
echo ""

echo "--- Processing Network Listeners (ss -tulpn) ---"
# 'sudo' is required for 'ss -p' to show process names/PIDs
if command -v ss &> /dev/null; then
    sudo ss -tulpn | awk "$AWK_SCRIPT"
else
    echo "Warning: 'ss' command not found. Skipping network listener scan."
fi
echo ""

echo "### Script Finished ###"
