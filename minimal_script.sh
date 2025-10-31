#!/bin/bash
# Minimal Bash Menu - Server Administration Script
# Compatible with basic terminals, no emojis, no fancy colors

# Configuration
MENU_TITLE="Server Administration Menu"
ENABLE_COLORS=false  # Disable colors for basic terminals

# Simple display functions
print_header() {
    echo "========================================"
    echo "     $MENU_TITLE"
    echo "========================================"
    echo ""
}

print_info() {
    echo "INFO: $1"
}

print_error() {
    echo "ERROR: $1"
}

print_success() {
    echo "SUCCESS: $1"
}

# Menu display
display_menu() {
    clear
    print_header
    echo "Available options:"
    echo "1. System Information"
    echo "2. Disk Usage"
    echo "3. Memory Usage"
    echo "4. Network Status"
    echo "5. Service Status"
    echo "6. Backup Database"
    echo "7. Update System"
    echo "8. Exit"
    echo ""
}

# Commands
cmd_system_info() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -s) $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')"
    echo "Memory: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
    echo ""
}

cmd_disk_usage() {
    echo "=== Disk Usage ==="
    df -h
    echo ""
    echo "=== Largest Directories ==="
    du -h --max-depth=1 / 2>/dev/null | sort -hr | head -10
    echo ""
}

cmd_memory_usage() {
    echo "=== Memory Usage ==="
    free -h
    echo ""
    echo "=== Top Memory Processes ==="
    ps aux --sort=-%mem | head -10
    echo ""
}

cmd_network_status() {
    echo "=== Network Interfaces ==="
    ip addr show | grep -E "^[0-9]+|^    inet" | head -10
    echo ""
    echo "=== Routing Table ==="
    ip route | head -5
    echo ""
}

cmd_service_status() {
    echo "=== Service Status ==="
    if command -v systemctl >/dev/null 2>&1; then
        systemctl list-units --type=service --state=running | head -10
    else
        echo "Systemctl not available"
        ps aux | grep -E "(sshd|nginx|apache|mysql)" | grep -v grep | head -5
    fi
    echo ""
}

cmd_backup_database() {
    echo "=== Database Backup ==="
    echo "Starting database backup..."
    # Add your database backup commands here
    # Example: mysqldump -u user -p database > /opt/backups/db_$(date +%Y%m%d).sql
    echo "Database backup completed"
    echo ""
}

cmd_update_system() {
    echo "=== System Update ==="
    echo "Checking for updates..."
    if command -v apt >/dev/null 2>&1; then
        apt update && apt upgrade -y
    elif command -v yum >/dev/null 2>&1; then
        yum update -y
    elif command -v dnf >/dev/null 2>&1; then
        dnf update -y
    else
        echo "Package manager not found"
    fi
    echo "System update completed"
    echo ""
}

# Main menu loop
main() {
    while true; do
        display_menu
        read -p "Enter your choice (1-8): " choice

        case $choice in
            1) cmd_system_info ;;
            2) cmd_disk_usage ;;
            3) cmd_memory_usage ;;
            4) cmd_network_status ;;
            5) cmd_service_status ;;
            6) cmd_backup_database ;;
            7) cmd_update_system ;;
            8) echo "Exiting. Goodbye!"; exit 0 ;;
            *) print_error "Invalid choice. Please enter a number between 1 and 8." ;;
        esac

        echo "Press Enter to continue..."
        read -s
    done
}

# Run main function
main