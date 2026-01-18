#!/bin/bash

# =============================================================================
# Professional Demo Script for Enhanced Bashmenu
# =============================================================================
# Description: Demonstrate all professional UI enhancements
# Version:     3.0
# =============================================================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source required modules
source "$PROJECT_ROOT/src/professional_themes.sh"
source "$PROJECT_ROOT/src/enhanced_menu_display.sh"
source "$PROJECT_ROOT/src/ui_enhanced.sh"

# =============================================================================
# Demo Menu Data
# =============================================================================

# Sample menu items for demonstration
declare -a DEMO_MENU_ITEMS=(
    "System Monitoring"
    "Process Management"
    "Network Tools"
    "File Operations"
    "User Administration"
    "Service Management"
    "Security Scanner"
    "Backup & Restore"
    "Log Analysis"
    "Performance Tuning"
    "Database Tools"
    "Docker Management"
    "System Updates"
    "Resource Monitor"
    "Configuration Editor"
)

declare -a DEMO_MENU_DESCRIPTIONS=(
    "Monitor CPU, memory, disk usage and system health"
    "View, manage and terminate running processes"
    "Network diagnostics, port scanning and monitoring"
    "File search, compression and disk cleanup"
    "Create, modify and manage user accounts"
    "Start, stop and configure system services"
    "Security vulnerability scanning and hardening"
    "Automated backup and system restore utilities"
    "System log analysis and troubleshooting tools"
    "Optimize system performance and resource usage"
    "Database administration and query tools"
    "Container management and orchestration"
    "System package updates and patch management"
    "Real-time resource monitoring and alerts"
    "Edit system configuration files safely"
)

# =============================================================================
# Theme Demonstration
# =============================================================================

demo_theme_showcase() {
    local -a themes=("modern_corporate" "dark_professional" "minimal_elegant" "tech_startup")
    
    for theme in "${themes[@]}"; do
        enhanced_menu_loop DEMO_MENU_ITEMS DEMO_MENU_DESCRIPTIONS \
            "Theme Showcase" "Current theme: $theme" "$theme"
        
        if [[ $? -eq 1 ]]; then
            break  # User quit
        fi
        
        show_status_notification "Theme '$theme' demonstration complete" "success" 1
        sleep 1
    done
}

# =============================================================================
# Feature Demonstration Functions
# =============================================================================

demo_transitions() {
    echo "=== Professional Transitions Demo ==="
    echo ""
    
    echo "Testing fade transition..."
    smooth_transition "fade"
    sleep 1
    
    echo "Testing slide up transition..."
    smooth_transition "slide_up"
    sleep 1
    
    echo "Testing wipe transition..."
    smooth_transition "wipe"
    sleep 1
    
    echo ""
}

demo_spinners() {
    echo "=== Professional Spinners Demo ==="
    echo ""
    
    local -a styles=("dots" "line" "arrow" "box" "bounce" "circle" "pulse" "grow")
    
    for style in "${styles[@]}"; do
        echo "Testing $style spinner..."
        professional_spinner "Loading with $style style" 2 "$style"
        echo ""
    done
    
    echo "Spinners demo complete!"
}

demo_progress_bars() {
    echo "=== Professional Progress Bars Demo ==="
    echo ""
    
    for i in {0..100..20}; do
        professional_progress_bar $i 100 50 "Installing"
        sleep 0.3
    done
    echo ""
    
    for i in {0..100..25}; do
        professional_progress_bar $i 100 50 "Downloading"
        sleep 0.3
    done
    echo ""
    
    echo "Progress bars demo complete!"
}

demo_notifications() {
    echo "=== Status Notifications Demo ==="
    echo ""
    
    show_status_notification "This is an info notification" "info" 2
    sleep 3
    
    show_status_notification "Operation completed successfully!" "success" 2
    sleep 3
    
    show_status_notification "Low disk space detected" "warning" 2
    sleep 3
    
    show_status_notification "Connection failed" "error" 2
    sleep 3
    
    echo ""
    echo "Notifications demo complete!"
}

# =============================================================================
# Menu Integration Demo
# =============================================================================

demo_enhanced_menu() {
    echo "=== Enhanced Professional Menu Demo ==="
    echo ""
    echo "Launching enhanced menu with all features..."
    sleep 2
    
    enhanced_menu_loop DEMO_MENU_ITEMS DEMO_MENU_DESCRIPTIONS \
        "Enhanced Menu Demo" "Navigate with ↑↓ • Press 's' to search • 't' for themes" \
        "modern_corporate"
    
    local result=$?
    
    echo ""
    if [[ $result -eq 0 ]]; then
        echo "Menu exited with selection"
    else
        echo "Menu was quit by user"
    fi
}

demo_search_functionality() {
    echo "=== Search Functionality Demo ==="
    echo ""
    echo "Testing search interface..."
    sleep 1
    
    # Simulate search mode
    MENU_SEARCH_QUERY="system"
    display_search_interface DEMO_MENU_ITEMS DEMO_MENU_DESCRIPTIONS
    
    echo ""
    echo "Press any key to continue..."
    read -n1 -s
    
    MENU_SEARCH_QUERY="network"
    display_search_interface DEMO_MENU_ITEMS DEMO_MENU_DESCRIPTIONS
    
    echo ""
    echo "Press any key to continue..."
    read -n1 -s
    
    MENU_SEARCH_QUERY=""
}

# =============================================================================
# Interactive Demo Menu
# =============================================================================

show_demo_menu() {
    while true; do
        clear
        load_professional_theme "modern_corporate"
        
        render_professional_header "Professional UI Demo" "Choose a feature to demonstrate"
        
        local demo_items=(
            "Enhanced Professional Menu"
            "Theme Showcase"
            "Smooth Transitions"
            "Professional Spinners"
            "Progress Bars"
            "Status Notifications"
            "Search Functionality"
            "Help System"
            "Run All Demos"
            "Exit Demo"
        )
        
        local demo_descriptions=(
            "Complete professional menu with all features"
            "Demonstrate all available themes"
            "Show smooth screen transitions"
            "Display modern loading animations"
            "Show enhanced progress indicators"
            "Show temporary status notifications"
            "Demonstrate search functionality"
            "Show comprehensive help system"
            "Run all demonstrations sequentially"
            "Exit the demo program"
        )
        
        for ((i=0; i<${#demo_items[@]}; i++)); do
            render_professional_menu_item "$i" "${demo_items[$i]}" "${demo_descriptions[$i]}" "false"
        done
        
        render_professional_footer "↑↓ Navigate • Enter Select • q Quit"
        
        # Read user input
        read -rsn1 choice
        
        case "$choice" in
            "0")
                demo_enhanced_menu
                ;;
            "1")
                demo_theme_showcase
                ;;
            "2")
                demo_transitions
                ;;
            "3")
                demo_spinners
                ;;
            "4")
                demo_progress_bars
                ;;
            "5")
                demo_notifications
                ;;
            "6")
                demo_search_functionality
                ;;
            "7")
                display_enhanced_help
                read -n1 -s
                ;;
            "8")
                demo_enhanced_menu
                demo_theme_showcase
                demo_transitions
                demo_spinners
                demo_progress_bars
                demo_notifications
                demo_search_functionality
                ;;
            "9"|"q")
                echo "Exiting demo..."
                exit 0
                ;;
            $'\x0a')  # Enter
                echo "Default: Enhanced Menu"
                demo_enhanced_menu
                ;;
        esac
        
        echo ""
        echo "Press any key to continue..."
        read -n1 -s
    done
}

# =============================================================================
# Main Entry Point
# =============================================================================

main() {
    echo "Initializing Professional Bashmenu Demo..."
    echo ""
    sleep 2
    
    # Show main demo menu
    show_demo_menu
}

# Check if script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi