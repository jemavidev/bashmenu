# Fallback logging functions (if not already defined)
if ! declare -f log_warn >/dev/null; then
  log_warn() { echo -e "[WARN] $*" >&2; }
fi
if ! declare -f log_info >/dev/null; then
  log_info() { echo -e "[INFO] $*" >&2; }
fi
if ! declare -f log_error >/dev/null; then
  log_error() { echo -e "[ERROR] $*" >&2; }
fi
if ! declare -f log_debug >/dev/null; then
  log_debug() { echo -e "[DEBUG] $*" >&2; }
fi

# Get system information
get_system_info() {
    echo -e "${CYAN}Hostname:${NC} $(hostname)"
    echo -e "${CYAN}OS:${NC} $(lsb_release -d | cut -f2 2>/dev/null || echo "Unknown")"
    echo -e "${CYAN}Kernel:${NC} $(uname -r)"
    echo -e "${CYAN}Uptime:${NC} $(uptime -p | sed 's/up //')"
    echo -e "${CYAN}CPU:${NC} $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')"
    echo -e "${CYAN}Memory:${NC} $(free -h | grep Mem | awk '{print $3 "/" $2}')"
}

# =============================================================================
# Command Functions
# =============================================================================

# System Information Command
cmd_system_info() {
    clear
    print_header "System Information"
    echo ""
    get_system_info
    echo ""
    echo -e "${CYAN}=== Detailed System Info ===${NC}"
    echo "Architecture: $(uname -m)"
    echo "Kernel Version: $(uname -r)"
    echo "Distribution: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || echo "Unknown")"
    echo "Shell: $SHELL"
    echo "User: $(whoami)"
    echo "Home: $HOME"
    echo ""
    echo -e "${CYAN}=== Hardware Details ===${NC}"
    echo "CPU Cores: $(nproc)"
    echo "Total Memory: $(free -h | grep Mem | awk '{print $2}')"
    echo "Available Memory: $(free -h | grep Mem | awk '{print $7}')"
    echo "Swap: $(free -h | grep Swap | awk '{print $3 "/" $2}')"
    echo ""
}

# Disk Usage Command
cmd_disk_usage() {
    clear
    print_header "Disk Usage Information"
    echo ""
    echo -e "${CYAN}=== Disk Space Usage ===${NC}"
    df -h
    echo ""
    echo -e "${CYAN}=== Inode Usage ===${NC}"
    df -i
    echo ""
    echo -e "${CYAN}=== Largest Directories ===${NC}"
    du -h --max-depth=1 / 2>/dev/null | sort -hr | head -10
    echo ""
}

# Memory Usage Command
cmd_memory_usage() {
    clear
    print_header "Memory Usage Information"
    echo ""
    echo -e "${CYAN}=== Memory Overview ===${NC}"
    free -h
    echo ""
    echo -e "${CYAN}=== Memory Details ===${NC}"
    cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree)"
    echo ""
    echo -e "${CYAN}=== Top Memory Processes ===${NC}"
    ps aux --sort=-%mem | head -10
    echo ""
}

# Running Processes Command
cmd_running_processes() {
    clear
    print_header "Running Processes"
    echo ""
    echo -e "${CYAN}=== Top CPU Processes ===${NC}"
    ps aux --sort=-%cpu | head -10
    echo ""
    echo -e "${CYAN}=== Top Memory Processes ===${NC}"
    ps aux --sort=-%mem | head -10
    echo ""
    echo -e "${CYAN}=== Process Count by User ===${NC}"
    ps aux | awk '{print $1}' | sort | uniq -c | sort -nr
    echo ""
}

# Network Status Command
cmd_network_status() {
    clear
    print_header "Network Status"
    echo ""
    echo -e "${CYAN}=== Network Interfaces ===${NC}"
    ip addr show
    echo ""
    echo -e "${CYAN}=== Network Connections ===${NC}"
    netstat -tuln 2>/dev/null || ss -tuln
    echo ""
    echo -e "${CYAN}=== Routing Table ===${NC}"
    ip route show
    echo ""
    echo -e "${CYAN}=== DNS Configuration ===${NC}"
    cat /etc/resolv.conf
    echo ""
}

# System Load Command
cmd_system_load() {
    clear
    print_header "System Load Information"
    echo ""
    echo -e "${CYAN}=== Current Load ===${NC}"
    uptime
    echo ""
    echo -e "${CYAN}=== Load Average History ===${NC}"
    cat /proc/loadavg
    echo ""
    echo -e "${CYAN}=== CPU Usage ===${NC}"
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1
    echo ""
    echo -e "${CYAN}=== System Uptime ===${NC}"
    uptime -p
    echo ""
}

# User Management Command
cmd_user_management() {
    clear
    print_header "User Management"
    echo ""
    echo -e "${CYAN}=== Currently Logged Users ===${NC}"
    who
    echo ""
    echo -e "${CYAN}=== User Login History ===${NC}"
    last | head -10
    echo ""
    echo -e "${CYAN}=== Failed Login Attempts ===${NC}"
    lastb 2>/dev/null | head -5 || echo "No failed login attempts found or insufficient permissions"
    echo ""
    echo -e "${CYAN}=== System Users ===${NC}"
    cat /etc/passwd | grep -E ":/bin/bash$|:/bin/sh$" | cut -d: -f1
    echo ""
}

# Package Updates Command
cmd_package_updates() {
    clear
    print_header "Package Updates"
    echo ""
    
    # Check if apt is available (Debian/Ubuntu)
    if command -v apt >/dev/null 2>&1; then
        echo -e "${CYAN}=== APT Package Updates ===${NC}"
        apt list --upgradable 2>/dev/null | head -20
        echo ""
        echo -e "${CYAN}=== APT Update Status ===${NC}"
        apt update 2>/dev/null | tail -5
    fi
    
    # Check if yum is available (RHEL/CentOS)
    if command -v yum >/dev/null 2>&1; then
        echo -e "${CYAN}=== YUM Package Updates ===${NC}"
        yum check-update 2>/dev/null | head -20
    fi
    
    # Check if dnf is available (Fedora)
    if command -v dnf >/dev/null 2>&1; then
        echo -e "${CYAN}=== DNF Package Updates ===${NC}"
        dnf check-update 2>/dev/null | head -20
    fi
    
    echo ""
    echo -e "${CYAN}=== Package Manager Info ===${NC}"
    echo "Available package managers:"
    [[ -f /usr/bin/apt ]] && echo "- APT (Debian/Ubuntu)"
    [[ -f /usr/bin/yum ]] && echo "- YUM (RHEL/CentOS)"
    [[ -f /usr/bin/dnf ]] && echo "- DNF (Fedora)"
    echo ""
}

# System Monitoring Command
cmd_monitor_system() {
    clear
    print_header "System Monitoring"
    echo ""
    echo -e "${CYAN}=== Real-time System Monitor ===${NC}"
    echo "Press Ctrl+C to exit monitoring"
    echo ""
    
    # Simple monitoring loop
    local count=0
    while [[ $count -lt 10 ]]; do
        echo -e "${YELLOW}--- Monitor Cycle $((count + 1)) ---${NC}"
        echo "Time: $(date '+%H:%M:%S')"
        echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
        echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
        echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
        echo ""
        sleep 2
        count=$((count + 1))
    done
}

# System Maintenance Command
cmd_system_maintenance() {
    clear
    print_header "System Maintenance"
    echo ""
    echo -e "${CYAN}=== Maintenance Tasks ===${NC}"
    echo "1. Clear package cache"
    echo "2. Clean temporary files"
    echo "3. Check disk space"
    echo "4. Update package lists"
    echo ""
    
    read -p "Select maintenance task (1-4) or press Enter to skip: " choice
    
    case $choice in
        1)
            echo -e "${GREEN}Clearing package cache...${NC}"
            if command -v apt >/dev/null 2>&1; then
                apt clean
            elif command -v yum >/dev/null 2>&1; then
                yum clean all
            elif command -v dnf >/dev/null 2>&1; then
                dnf clean all
            fi
            ;;
        2)
            echo -e "${GREEN}Cleaning temporary files...${NC}"
            rm -rf /tmp/* 2>/dev/null
            rm -rf /var/tmp/* 2>/dev/null
            ;;
        3)
            echo -e "${GREEN}Checking disk space...${NC}"
            df -h
            ;;
        4)
            echo -e "${GREEN}Updating package lists...${NC}"
            if command -v apt >/dev/null 2>&1; then
                apt update
            elif command -v yum >/dev/null 2>&1; then
                yum check-update
            elif command -v dnf >/dev/null 2>&1; then
                dnf check-update
            fi
            ;;
        *)
            echo -e "${YELLOW}No maintenance task selected${NC}"
            ;;
    esac
    echo ""
}

# Show Help Command
cmd_show_help() {
    clear
    print_header "Bashmenu Help"
    echo ""
    echo -e "${CYAN}=== Available Commands ===${NC}"
    echo "1. System Information - Show detailed system information"
    echo "2. Disk Usage - Show disk space usage"
    echo "3. Memory Usage - Show memory usage"
    echo "4. Running Processes - Show top running processes"
    echo "5. Network Status - Show network connections"
    echo "6. System Load - Show system load"
    echo "7. User Management - Show logged users"
    echo "8. Package Updates - Show available updates"
    echo "9. System Monitoring - Monitor system resources"
    echo "10. System Maintenance - Run maintenance tasks"
    echo ""
    echo -e "${CYAN}=== Keyboard Shortcuts ===${NC}"
    echo "• Arrow keys: Navigate menu"
    echo "• Enter: Select option"
    echo "• q: Quick exit"
    echo "• h: Show help"
    echo "• r: Refresh menu"
    echo ""
    echo -e "${CYAN}=== Navigation Tips ===${NC}"
    echo "• Use numbers (1-12) to quickly select options"
    echo "• Use arrow keys for navigation"
    echo "• Press 'q' to exit at any time"
    echo "• Press 'h' for help"
    echo ""
}

# =============================================================================
# Utility Functions
# =============================================================================

# Get user level for permissions
get_user_level() {
    if [[ "$(whoami)" == "root" ]]; then
        echo "3"
    elif [[ "$(whoami)" == "admin" ]]; then
        echo "2"
    else
        echo "1"
    fi
}

# Load plugins
load_plugins() {
    if [[ "${ENABLE_PLUGINS:-true}" == "true" && -d "${PLUGIN_DIR:-plugins}" ]]; then
        for plugin in "${PLUGIN_DIR:-plugins}"/*.sh; do
            if [[ -f "$plugin" ]]; then
                source "$plugin"
                log_info "Plugin loaded: $(basename "$plugin")"
            fi
        done
    fi
}

# Cleanup old backups
cleanup_old_backups() {
    if [[ "${AUTO_BACKUP:-true}" == "true" && -d "${BACKUP_DIR:-$HOME/.bashmenu/backups}" ]]; then
        local retention_days="${BACKUP_RETENTION_DAYS:-7}"
        find "${BACKUP_DIR:-$HOME/.bashmenu/backups}" -type f -mtime +$retention_days -delete 2>/dev/null
        log_info "Cleaned up backups older than $retention_days days"
    fi
}

# =============================================================================
# Export Functions
# =============================================================================

export -f cmd_system_info
export -f cmd_disk_usage
export -f cmd_memory_usage
export -f cmd_running_processes
export -f cmd_network_status
export -f cmd_system_load
export -f cmd_user_management
export -f cmd_package_updates
export -f cmd_monitor_system
export -f cmd_system_maintenance
export -f cmd_show_help
export -f get_user_level
export -f load_plugins
export -f cleanup_old_backups 