#!/bin/bash

# system_info.sh
# A basic Bash script to display system information.

# --- Script Information for Users ---
# This script provides a quick overview of:
# 1. Your current user's home directory.
# 2. The type of terminal you are using.
# 3. Services configured to start up in a typical multi-user, non-graphical server environment.
#    - For modern Linux systems (using systemd), this means services enabled for 'multi-user.target'.
#    - For older Linux systems (using SysVinit), this means services enabled for 'runlevel 3'.
#
# Usage:
#   1. Save the script: Copy the content into a file, e.g., 'system_info.sh'.
#   2. Make it executable: Open your terminal and run: chmod +x system_info.sh
#   3. Run the script: ./system_info.sh
#
# Prerequisites:
# - Bash shell (standard on most Linux systems).
# - Common system utilities like 'echo', 'env', 'systemctl', 'chkconfig', 'ls'.
#
# IMPORTANT NOTE ON SERVICES:
# The list of services reflects what is *configured* to start, not necessarily what is
# *currently running*. Services might fail to start, or you might have stopped them manually.
# For truly active services, 'systemctl status' or 'service --status-all' are better.
# This script focuses on the 'enabled' configuration for a specific boot target/runlevel.

echo "--- Basic System Information ---"
echo ""

# 1. Display Home Directory
echo "1. Your Home Directory:"
echo "   \$HOME variable: $HOME"
echo "   (~ shorthand):    ~"
echo ""

# 2. Display Terminal Type
echo "2. Your Terminal Type:"
# The TERM environment variable indicates the terminal type (e.g., xterm, screen, gnome-terminal)
echo "   \$TERM variable: $TERM"
echo ""

# 3. Show Services Started in Runlevel 3 (or equivalent)
echo "3. Services Configured for Runlevel 3 / Multi-User Target:"
echo "   (This lists services typically started in a non-graphical, networked server environment)"

# Check if systemd is running (most modern Linux distributions)
if command -v systemctl &>/dev/null; then
    echo "   Detected systemd. Showing services enabled for 'multi-user.target':"
    # List all unit files that are enabled (will start on boot for the default target)
    # Filter by services (.service suffix) and sort alphabetically
    # systemctl list-unit-files --type=service --state=enabled | grep "enabled" | awk '{print $1}' | sort
    # A more direct way to show services enabled for multi-user.target:
    # Get the dependencies of multi-user.target and filter for services
    systemctl show -p "Wants" multi-user.target | \
        sed 's/Wants=//' | \
        tr ' ' '\n' | \
        grep '.service$' | \
        sed 's/\.service$//' | \
        sort
elif command -v chkconfig &>/dev/null; then
    echo "   Detected chkconfig (SysVinit/RedHat-based). Showing services for runlevel 3:"
    # List services enabled for runlevel 3
    chkconfig --list | grep "3:on" | awk '{print $1}' | sort
elif command -v service &>/dev/null && command -v ls &>/dev/null && [ -d "/etc/rc3.d" ]; then
    echo "   Detected SysVinit (Debian/Ubuntu-based). Showing services in /etc/rc3.d:"
    # For Debian/Ubuntu-style SysVinit, services enabled for a runlevel are symbolic links
    # starting with 'S' in the corresponding /etc/rcX.d directory.
    ls -l /etc/rc3.d/S* | awk '{print $NF}' | sed 's/..\/init.d\///' | sort
else
    echo "   Could not determine service management system (systemd/SysVinit)."
    echo "   Unable to list services configured for startup in runlevel 3 equivalent."
    echo "   Please consult your system's documentation for service management."
fi
echo ""
echo "--- End of System Information ---"
