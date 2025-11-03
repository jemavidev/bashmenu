#!/bin/bash

# =============================================================================
# Bashmenu Commands
# =============================================================================
# Description: Core command implementations
# Version:     2.0
# =============================================================================

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

# =============================================================================
# Core Commands
# =============================================================================

# List files (ls -la)
cmd_list_files() {
    clear
    print_header "List Files (ls -la)"
    echo ""
    echo -e "${CYAN}Current directory: ${YELLOW}$(pwd)${NC}"
    echo ""
    print_separator
    ls -la
    echo ""
    print_separator
    echo -e "${GREEN}Tip: Use 'cd' command to change directory${NC}"
}

# List files detailed (ll)
cmd_list_detailed() {
    clear
    print_header "Detailed File List (ll)"
    echo ""
    echo -e "${CYAN}Current directory: ${YELLOW}$(pwd)${NC}"
    echo ""
    print_separator
    ls -lAh --color=auto
    echo ""
    print_separator
    echo -e "${GREEN}Showing all files with human-readable sizes${NC}"
}

# Disk usage (df -h)
cmd_disk_free() {
    clear
    print_header "Disk Space (df -h)"
    echo ""
    print_separator
    echo -e "${CYAN}Filesystem usage:${NC}"
    echo ""
    df -h | head -1
    df -h | grep -E '^/dev/'
    echo ""
    print_separator
    
    # Show summary
    local total_used=$(df -h / | awk 'NR==2 {print $3}')
    local total_avail=$(df -h / | awk 'NR==2 {print $4}')
    local usage_percent=$(df -h / | awk 'NR==2 {print $5}')
    
    echo -e "${CYAN}Root filesystem:${NC}"
    echo -e "  Used: ${YELLOW}$total_used${NC}"
    echo -e "  Available: ${YELLOW}$total_avail${NC}"
    echo -e "  Usage: ${YELLOW}$usage_percent${NC}"
}

# Memory usage (free -h)
cmd_memory_free() {
    clear
    print_header "Memory Usage (free -h)"
    echo ""
    print_separator
    echo -e "${CYAN}Memory information:${NC}"
    echo ""
    free -h
    echo ""
    print_separator
    
    # Show summary
    local mem_used=$(free -h | awk 'NR==2 {print $3}')
    local mem_total=$(free -h | awk 'NR==2 {print $2}')
    local mem_percent=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    
    echo -e "${CYAN}Summary:${NC}"
    echo -e "  Used: ${YELLOW}$mem_used${NC} / ${YELLOW}$mem_total${NC}"
    echo -e "  Usage: ${YELLOW}${mem_percent}%${NC}"
    
    # Visual bar
    show_bar "$mem_percent" 100
}

# Process list (ps aux)
cmd_process_list() {
    clear
    print_header "Process List (ps aux)"
    echo ""
    print_separator
    echo -e "${CYAN}Top 15 processes by CPU usage:${NC}"
    echo ""
    ps aux --sort=-%cpu | head -16
    echo ""
    print_separator
    
    # Show summary
    local total_procs=$(ps aux | wc -l)
    local running_procs=$(ps aux | grep -c " R ")
    
    echo -e "${CYAN}Summary:${NC}"
    echo -e "  Total processes: ${YELLOW}$total_procs${NC}"
    echo -e "  Running: ${YELLOW}$running_procs${NC}"
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

# Cleanup old backups
cleanup_old_backups() {
    if [[ "${AUTO_BACKUP:-true}" == "true" && -d "${BACKUP_DIR:-$HOME/.bashmenu/backups}" ]]; then
        local retention_days="${BACKUP_RETENTION_DAYS:-7}"
        find "${BACKUP_DIR:-$HOME/.bashmenu/backups}" -type f -mtime +$retention_days -delete 2>/dev/null
        if declare -f log_info >/dev/null; then
            log_info "Cleaned up backups older than $retention_days days"
        fi
    fi
}

# =============================================================================
# Export Functions
# =============================================================================

export -f cmd_list_files
export -f cmd_list_detailed
export -f cmd_disk_free
export -f cmd_memory_free
export -f cmd_process_list
export -f get_user_level
export -f cleanup_old_backups
