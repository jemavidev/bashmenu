#!/bin/bash

# =============================================================================
# Bashmenu - Enhanced System Administration Menu
# =============================================================================
# Description: Main entry point for the enhanced Bashmenu system
# Version:     2.0
# Author:      JESUS VILLALOBOS (Enhanced with AI assistance)
# =============================================================================

# =============================================================================
# Shell Compatibility Check
# =============================================================================

# Ensure we're running with bash
if [[ -z "$BASH_VERSION" ]]; then
    echo "Error: This script must be run with bash, not $0" >&2
    echo "Please run: bash $0" >&2
    exit 1
fi

# Check for associative array support (bash >= 4.0)
if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
    echo "Error: This script requires bash version 4.0 or higher" >&2
    echo "Current version: $BASH_VERSION" >&2
    exit 1
fi

# =============================================================================
# Script Information
# =============================================================================

readonly SCRIPT_NAME="Bashmenu"
readonly SCRIPT_VERSION="2.0"
readonly SCRIPT_AUTHOR="JESUS VILLALOBOS"

# =============================================================================
# Global Variables
# =============================================================================

# Script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Configuration file
readonly CONFIG_FILE="$PROJECT_ROOT/config/config.conf"

# =============================================================================
# Color Definitions (fallback)
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# =============================================================================
# Utility Functions (fallback)
# =============================================================================

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_header() {
    local title="$1"
    local width=50
    local padding=$(( (width - ${#title}) / 2 ))
    
    echo -e "${CYAN}"
    printf "%${width}s\n" | tr ' ' '='
    printf "%${padding}s%s%${padding}s\n" "" "$title" ""
    printf "%${width}s\n" | tr ' ' '='
    echo -e "${NC}"
}

# =============================================================================
# Validation Functions
# =============================================================================

check_requirements() {
    print_info "Checking system requirements..."
    
    local errors=0
    
    # Check required commands
    local required_commands=("bash" "clear" "date" "hostname" "uname")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            print_error "Required command not found: $cmd"
            errors=$((errors + 1))
        fi
    done
    
    # Check if source files exist
    local required_files=("utils.sh" "commands.sh" "menu.sh")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
            print_error "Required file not found: $file"
            errors=$((errors + 1))
        fi
    done
    
    if [[ $errors -gt 0 ]]; then
        print_error "Requirements check failed ($errors errors)"
        return 1
    fi
    
    print_success "Requirements check passed"
    return 0
}

# =============================================================================
# Initialization Functions
# =============================================================================

initialize_system() {
    print_info "Initializing Bashmenu system..."
    
    # Load configuration
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        print_success "Configuration loaded from $CONFIG_FILE"
    else
        print_warning "Configuration file not found, using defaults"
        set_default_config
    fi
    
    # Load modules
    load_modules
    
    # Initialize menu
    if declare -f initialize_menu >/dev/null; then
        initialize_menu
        print_success "Menu initialized"
    else
        print_error "Menu initialization failed"
        return 1
    fi
    
    # Load theme
    if declare -f load_theme >/dev/null; then
        load_theme "${DEFAULT_THEME:-default}"
        print_success "Theme loaded: ${DEFAULT_THEME:-default}"
    else
        print_error "Theme loading failed"
        return 1
    fi
    
    print_success "System initialization completed"
    return 0
}

load_modules() {
    print_info "Loading system modules..."
    
    # Load utilities
    if [[ -f "$SCRIPT_DIR/utils.sh" ]]; then
        source "$SCRIPT_DIR/utils.sh"
        print_success "Utils module loaded"
    else
        print_error "Utils module not found"
        return 1
    fi
    
    # Load commands
    if [[ -f "$SCRIPT_DIR/commands.sh" ]]; then
        source "$SCRIPT_DIR/commands.sh"
        print_success "Commands module loaded"
    else
        print_error "Commands module not found"
        return 1
    fi
    
    # Load menu system
    if [[ -f "$SCRIPT_DIR/menu.sh" ]]; then
        source "$SCRIPT_DIR/menu.sh"
        print_success "Menu module loaded"
        
        # Verify that themes were loaded correctly
        if [[ -z "$default_frame_top" ]]; then
            print_error "Themes not loaded correctly"
            return 1
        fi
    else
        print_error "Menu module not found"
        return 1
    fi
    
    return 0
}

set_default_config() {
    # Set default configuration values
    MENU_TITLE="System Administration Menu"
    ENABLE_COLORS=true
    AUTO_REFRESH=false
    SHOW_TIMESTAMP=true
    DEFAULT_THEME="default"
    LOG_LEVEL=1
    LOG_FILE="/tmp/bashmenu.log"
    ENABLE_HISTORY=true
    HISTORY_FILE="$HOME/.bashmenu_history.log"
    ENABLE_PERMISSIONS=false
    ENABLE_PLUGINS=true
    PLUGIN_DIR="$PROJECT_ROOT/plugins"
    ENABLE_NOTIFICATIONS=true
    NOTIFICATION_DURATION=3000
    AUTO_BACKUP=true
    BACKUP_RETENTION_DAYS=7
    BACKUP_DIR="$HOME/.bashmenu/backups"
}

# =============================================================================
# Welcome and Information Functions
# =============================================================================

show_welcome() {
    clear
    print_header "Welcome to $SCRIPT_NAME v$SCRIPT_VERSION"
    echo ""
    echo -e "${GREEN}System Information:${NC}"
    echo "Hostname: $(hostname)"
    echo "OS: $(lsb_release -d | cut -f2 2>/dev/null || echo "Unknown")"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p | sed 's/up //')"
    echo "User: $(whoami)"
    echo ""
    
    if [[ "${ENABLE_PLUGINS:-true}" == "true" ]]; then
        echo -e "${CYAN}Plugin System:${NC} Enabled"
    fi
    
    if [[ "${ENABLE_PERMISSIONS:-false}" == "true" ]]; then
        echo -e "${CYAN}Permission System:${NC} Enabled"
    fi
    
    echo ""
    echo -e "${GREEN}Ready to start!${NC}"
    echo ""
    sleep 2
}

show_system_info() {
    print_header "System Information"
    echo ""
    echo -e "${CYAN}=== Basic Info ===${NC}"
    echo "Hostname: $(hostname)"
    echo "OS: $(lsb_release -d | cut -f2 2>/dev/null || echo "Unknown")"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Uptime: $(uptime -p | sed 's/up //')"
    echo ""
    
    echo -e "${CYAN}=== Hardware Info ===${NC}"
    echo "CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')"
    echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
    echo "Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
    echo ""
    
    echo -e "${CYAN}=== Bashmenu Info ===${NC}"
    echo "Version: $SCRIPT_VERSION"
    echo "Author: $SCRIPT_AUTHOR"
    echo "Configuration: $CONFIG_FILE"
    echo "Log File: ${LOG_FILE:-/tmp/bashmenu.log}"
    echo ""
}

# =============================================================================
# Main Functions
# =============================================================================

main() {
    # Check requirements
    if ! check_requirements; then
        print_error "System requirements not met. Exiting."
        exit 1
    fi
    
    # Initialize system
    if ! initialize_system; then
        print_error "System initialization failed. Exiting."
        exit 1
    fi
    
    # Show welcome
    show_welcome
    
    # Start menu loop
    if declare -f menu_loop >/dev/null; then
        menu_loop
    else
        print_error "Menu loop function not found"
        exit 1
    fi
}

# =============================================================================
# Help Functions
# =============================================================================

show_help() {
    print_header "Bashmenu Help"
    echo ""
    echo -e "${CYAN}Usage:${NC}"
    echo "  bash main.sh [options]"
    echo ""
    echo -e "${CYAN}Options:${NC}"
    echo "  --help, -h     Show this help message"
    echo "  --version, -v  Show version information"
    echo "  --info, -i     Show system information"
    echo "  --config, -c   Show configuration information"
    echo ""
    echo -e "${CYAN}Features:${NC}"
    echo "  • Interactive menu system"
    echo "  • Multiple themes support"
    echo "  • Plugin system"
    echo "  • Permission-based access control"
    echo "  • Comprehensive logging"
    echo "  • System monitoring tools"
    echo "  • Configuration management"
    echo ""
    echo -e "${CYAN}Keyboard Shortcuts:${NC}"
    echo "  • Arrow keys: Navigate menu"
    echo "  • Enter: Select option"
    echo "  • q: Quick exit"
    echo "  • h: Show help"
    echo "  • r: Refresh menu"
    echo ""
}

show_version() {
    print_header "Version Information"
    echo ""
    echo "Bashmenu v$SCRIPT_VERSION"
    echo "Author: $SCRIPT_AUTHOR"
    echo "License: MIT"
    echo ""
    echo "Enhanced system administration menu with:"
    echo "• Modular architecture"
    echo "• Plugin support"
    echo "• Theme system"
    echo "• Permission controls"
    echo "• Comprehensive logging"
    echo ""
}

show_config_info() {
    print_header "Configuration Information"
    echo ""
    
    if [[ -f "$CONFIG_FILE" ]]; then
        echo -e "${GREEN}Configuration file:${NC} $CONFIG_FILE"
        echo ""
        echo -e "${CYAN}Current Settings:${NC}"
        echo "Menu Title: ${MENU_TITLE:-Not set}"
        echo "Default Theme: ${DEFAULT_THEME:-default}"
        echo "Enable Colors: ${ENABLE_COLORS:-true}"
        echo "Show Timestamp: ${SHOW_TIMESTAMP:-true}"
        echo "Enable Permissions: ${ENABLE_PERMISSIONS:-false}"
        echo "Enable Plugins: ${ENABLE_PLUGINS:-true}"
        echo "Enable Notifications: ${ENABLE_NOTIFICATIONS:-true}"
        echo "Log Level: ${LOG_LEVEL:-1}"
        echo "Log File: ${LOG_FILE:-/tmp/bashmenu.log}"
        echo ""
    else
        echo -e "${YELLOW}No configuration file found${NC}"
        echo "Using default settings"
        echo ""
    fi
}

# =============================================================================
# Command Line Interface
# =============================================================================

parse_arguments() {
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        --version|-v)
            show_version
            exit 0
            ;;
        --info|-i)
            show_system_info
            exit 0
            ;;
        --config|-c)
            show_config_info
            exit 0
            ;;
        "")
            # No arguments, run main program
            main "$@"
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

# =============================================================================
# Signal Handling
# =============================================================================

cleanup() {
    echo ""
    print_info "Cleaning up..."
    
    # Cleanup old backups if function exists
    if declare -f cleanup_old_backups >/dev/null; then
        cleanup_old_backups
    fi
    
    print_success "Cleanup completed"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# =============================================================================
# Main Entry Point
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_arguments "$@"
fi 