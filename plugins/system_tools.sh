#!/bin/bash

# =============================================================================
# System Tools Plugin for Bashmenu
# =============================================================================
# Description: Basic system commands wrapper
# Author:      Bashmenu Team
# Version:     2.0
# =============================================================================

# Source utilities if not already sourced
if [[ -z "$RED" ]]; then
    source "$(dirname "$0")/../src/utils.sh"
fi

# =============================================================================
# Plugin Information
# =============================================================================

PLUGIN_NAME="System Tools"
PLUGIN_VERSION="2.0"
PLUGIN_DESCRIPTION="Basic system commands (ls, df, free, ps, uptime)"

# =============================================================================
# Plugin Functions - Simple Command Wrappers
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
# Plugin Registration
# =============================================================================

# Register plugin commands with the main menu
register_plugin_commands() {
    # Only add plugin commands if external scripts are not loaded
    if [[ -z "${EXTERNAL_SCRIPTS:-}" ]]; then
        # Add simple command wrappers
        add_menu_item "List Files (ls)" "cmd_list_files" "Show files in current directory" 1
        add_menu_item "List Detailed (ll)" "cmd_list_detailed" "Detailed file listing" 1
        add_menu_item "Disk Space (df)" "cmd_disk_free" "Show disk usage" 1
        add_menu_item "Memory (free)" "cmd_memory_free" "Show memory usage" 1
        add_menu_item "Processes (ps)" "cmd_process_list" "Show running processes" 1

        if declare -f log_info >/dev/null; then
            log_info "System Tools plugin: 5 commands registered"
        fi
    fi
}

# Auto-register when plugin is loaded
register_plugin_commands 