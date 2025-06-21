#!/bin/bash

# mysystem.sh - A script to display system information using printf

# --- ANSI Color Codes for pretty output ---
RED='\033[0;31m'
GREEN='\033[0m' # No Color
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Section Header Function ---
print_section_header() {
    printf "${CYAN}---------------------------------------------------\n"
    printf "| %-47s |\n" "$1"
    printf "---------------------------------------------------${NC}\n"
}

# --- System Overview ---
print_section_header "System Overview"
printf "${BLUE}%-20s %s\n" "Hostname:" "$(hostname)"
printf "%-20s %s\n" "Uptime:" "$(uptime -p)"
printf "%-20s %s\n" "Current User:" "$(whoami)"
printf "%-20s %s\n" "Logged-in Users:" "$(who | wc -l)"
printf "%-20s %s\n" "Current Date/Time:" "$(date '+%Y-%m-%d %H:%M:%S %Z')"
printf "%-20s %s\n" "Operating System:" "$(hostnamectl | grep "Operating System" | cut -d':' -f2 | xargs)"
printf "%-20s %s\n" "Kernel Version:" "$(uname -r)"
printf "%-20s %s\n" "Architecture:" "$(uname -m)"
printf "${NC}\n"

# --- CPU Information ---
print_section_header "CPU Information"
CPU_MODEL=$(grep -m 1 'model name' /proc/cpuinfo | cut -d':' -f2 | xargs)
CPU_CORES=$(grep -c '^processor' /proc/cpuinfo)
CPU_THREADS_PER_CORE=$(grep 'siblings' /proc/cpuinfo | head -1 | awk '{print $3}')
CPU_CORES_PER_SOCKET=$(grep 'cpu cores' /proc/cpuinfo | head -1 | awk '{print $4}')
CPU_SOCKETS=$(grep 'physical id' /proc/cpuinfo | sort -u | wc -l)

printf "${BLUE}%-25s %s\n" "Model:" "$CPU_MODEL"
printf "%-25s %s\n" "Total Cores (Logical):" "$CPU_CORES"
printf "%-25s %s\n" "CPU Sockets:" "$CPU_SOCKETS"
printf "%-25s %s\n" "Cores per Socket:" "$CPU_CORES_PER_SOCKET"
printf "%-25s %s\n" "Threads per Core:" "$CPU_THREADS_PER_CORE"
printf "${NC}\n"

# --- Memory Information ---
print_section_header "Memory Information"
MEM_TOTAL_KB=$(grep 'MemTotal' /proc/meminfo | awk '{print $2}')
MEM_FREE_KB=$(grep 'MemFree' /proc/meminfo | awk '{print $2}')
MEM_AVAILABLE_KB=$(grep 'MemAvailable' /proc/meminfo | awk '{print $2}')
SWAP_TOTAL_KB=$(grep 'SwapTotal' /proc/meminfo | awk '{print $2}')
SWAP_FREE_KB=$(grep 'SwapFree' /proc/meminfo | awk '{print $2}')

# Convert to GB for display
MEM_TOTAL_GB=$(printf "%.2f" "$(echo "scale=2; $MEM_TOTAL_KB / (1024*1024)" | bc)")
MEM_FREE_GB=$(printf "%.2f" "$(echo "scale=2; $MEM_FREE_KB / (1024*1024)" | bc)")
MEM_AVAILABLE_GB=$(printf "%.2f" "$(echo "scale=2; $MEM_AVAILABLE_KB / (1024*1024)" | bc)")
SWAP_TOTAL_GB=$(printf "%.2f" "$(echo "scale=2; $SWAP_TOTAL_KB / (1024*1024)" | bc)")
SWAP_FREE_GB=$(printf "%.2f" "$(echo "scale=2; $SWAP_FREE_KB / (1024*1024)" | bc)")

printf "${BLUE}%-20s %10s GB\n" "Total RAM:" "$MEM_TOTAL_GB"
printf "%-20s %10s GB\n" "Free RAM:" "$MEM_FREE_GB"
printf "%-20s %10s GB\n" "Available RAM:" "$MEM_AVAILABLE_GB"
printf "%-20s %10s GB\n" "Total Swap:" "$SWAP_TOTAL_GB"
printf "%-20s %10s GB\n" "Free Swap:" "$SWAP_FREE_GB"
printf "${NC}\n"

# --- Disk Usage ---
print_section_header "Disk Usage (Filesystems)"
printf "${YELLOW}%-20s %10s %10s %10s %10s %s\n" "Filesystem" "Size" "Used" "Avail" "Use%" "Mounted on"
df -h --output=source,size,used,avail,pcent,target | tail -n +2 | while read -r line; do
    printf "${GREEN}%-20s %10s %10s %10s %10s %s\n" $line
done
printf "${NC}\n"

# --- Network Information ---
print_section_header "Network Information"
printf "${YELLOW}%-15s %-20s %s\n" "Interface" "IP Address" "MAC Address"
ip -o link show | awk '{print $2, $17}' | sed 's/://g' | while read -r iface mac; do
    IP_ADDRESS=$(ip -o -4 addr show dev "${iface%:}" | awk '{print $4}' | cut -d'/' -f1)
    if [ -z "$IP_ADDRESS" ]; then
        IP_ADDRESS="N/A"
    fi
    printf "${GREEN}%-15s %-20s %s\n" "${iface%:}" "$IP_ADDRESS" "$mac"
done
printf "${NC}\n"

# --- Top 5 Processes by Memory Usage ---
print_section_header "Top 5 Processes (Memory)"
printf "${YELLOW}%-10s %-10s %-15s %s\n" "PID" "USER" "%MEM" "COMMAND"
ps aux --sort=-%mem | awk 'NR<=6 {printf "%-10s %-10s %-15s %s\n", $2, $1, $4, $11}'
printf "${NC}\n"

# --- Top 5 Processes by CPU Usage ---
print_section_header "Top 5 Processes (CPU)"
printf "${YELLOW}%-10s %-10s %-15s %s\n" "PID" "USER" "%CPU" "COMMAND"
ps aux --sort=-%cpu | awk 'NR<=6 {printf "%-10s %-10s %-15s %s\n", $2, $1, $3, $11}'
printf "${NC}\n"

# --- Current Load Averages ---
print_section_header "Load Averages"
LOAD_AVERAGES=$(uptime | awk -F'load average:' '{print $2}' | xargs)
printf "${BLUE}%-20s %s\n" "1 min, 5 min, 15 min:" "$LOAD_AVERAGES"
printf "${NC}\n"

# --- Done ---
printf "${MAGENTA}--- End of System Information ---${NC}\n"
