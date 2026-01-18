#!/bin/bash

# =============================================================================
# Bashmenu UI/UX Demo Script
# =============================================================================
# This script demonstrates all the new UI/UX enhancements in Bashmenu
# =============================================================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source required modules
source "$PROJECT_ROOT/src/ui_enhanced.sh"
source "$PROJECT_ROOT/src/dialog_wrapper.sh"
source "$PROJECT_ROOT/src/fzf_integration.sh"
source "$PROJECT_ROOT/src/notifications.sh"

# =============================================================================
# Demo Functions
# =============================================================================

demo_spinners() {
    echo "=== Spinner Animations Demo ==="
    echo ""
    
    local styles=("dots" "line" "arrow" "box" "bounce" "circle" "pulse" "grow")
    
    for style in "${styles[@]}"; do
        echo "Testing $style spinner..."
        show_spinner "Loading with $style style" "$style" &
        local spinner_pid=$!
        sleep 2
        kill $spinner_pid 2>/dev/null
        wait $spinner_pid 2>/dev/null
        echo ""
    done
    
    echo "Spinners demo complete!"
    echo ""
}

demo_progress_bars() {
    echo "=== Progress Bar Demo ==="
    echo ""
    
    for i in {0..100..10}; do
        show_progress_bar $i 100 50 "Installing"
        sleep 0.2
    done
    echo ""
    
    echo "Progress bar demo complete!"
    echo ""
}

demo_gradients() {
    echo "=== Gradient Text Demo ==="
    echo ""
    
    print_gradient "Cyan Gradient Text" "cyan"
    print_gradient "Green Gradient Text" "green"
    print_gradient "Purple Gradient Text" "purple"
    print_gradient "Sunset Gradient Text" "sunset"
    
    echo ""
    echo "Gradients demo complete!"
    echo ""
}

demo_banners() {
    echo "=== Banner Demo ==="
    echo ""
    
    print_banner "BASHMENU" "simple"
    echo ""
    print_banner "MODERN UI" "double"
    echo ""
    print_banner "ENHANCED" "neon"
    
    echo ""
    echo "Banners demo complete!"
    echo ""
}

demo_notifications() {
    echo "=== Notification Demo ==="
    echo ""
    
    show_notification_banner "This is an info notification" "info"
    sleep 2
    
    show_notification_banner "This is a success notification" "success"
    sleep 2
    
    show_notification_banner "This is a warning notification" "warning"
    sleep 2
    
    show_notification_banner "This is an error notification" "error"
    sleep 2
    
    echo ""
    echo "Notifications demo complete!"
    echo ""
}

demo_terminal_notifications() {
    echo "=== Terminal Notification Banners Demo ==="
    echo ""
    
    show_info_banner "Processing your request..." 2
    sleep 2
    
    show_success_banner "Operation completed successfully!" 2
    sleep 2
    
    show_warning_banner "Low disk space detected" 2
    sleep 2
    
    show_error_banner "Connection failed" 2
    sleep 2
    
    echo ""
    echo "Terminal notifications demo complete!"
    echo ""
}

demo_desktop_notifications() {
    echo "=== Desktop Notification Demo ==="
    echo ""
    
    if is_notify_send_available; then
        send_notification "Bashmenu Demo" "This is a test notification" "normal" "dialog-information"
        echo "Desktop notification sent!"
        sleep 2
        
        send_success_notification "Success" "Operation completed"
        echo "Success notification sent!"
        sleep 2
        
        send_warning_notification "Warning" "Please check system status"
        echo "Warning notification sent!"
        sleep 2
        
        send_error_notification "Error" "Something went wrong"
        echo "Error notification sent!"
        sleep 2
    else
        echo "notify-send not available. Install with: sudo apt install libnotify-bin"
    fi
    
    echo ""
    echo "Desktop notifications demo complete!"
    echo ""
}

demo_dialog() {
    echo "=== Dialog/Whiptail Demo ==="
    echo ""
    
    if is_dialog_available; then
        echo "Dialog tool detected: $DIALOG_TOOL"
        
        # Message box
        show_dialog_msgbox "Demo" "This is a message box demo"
        
        # Yes/No dialog
        if show_dialog_yesno "Question" "Do you want to continue with the demo?"; then
            echo "User selected: Yes"
        else
            echo "User selected: No"
        fi
        
        # Input box
        local user_input
        user_input=$(show_dialog_input "Input" "Enter your name:")
        if [[ -n "$user_input" ]]; then
            echo "User entered: $user_input"
        fi
        
        # Menu
        local items=("1" "Option One" "2" "Option Two" "3" "Option Three")
        local selection
        selection=$(show_dialog_menu "Menu Demo" "Select an option:" "${items[@]}")
        if [[ -n "$selection" ]]; then
            echo "User selected: $selection"
        fi
        
    else
        echo "dialog/whiptail not available. Install with: sudo apt install dialog"
    fi
    
    echo ""
    echo "Dialog demo complete!"
    echo ""
}

demo_fzf() {
    echo "=== fzf Search Demo ==="
    echo ""
    
    if is_fzf_available; then
        echo "fzf detected!"
        
        # Create sample data
        local -a sample_options=("Install Package" "Update System" "Check Status" "View Logs" "Backup Data")
        local -a sample_descriptions=("Install a new package" "Update system packages" "Check system status" "View system logs" "Backup important data")
        
        # Simulate menu arrays
        menu_options=("${sample_options[@]}")
        menu_descriptions=("${sample_descriptions[@]}")
        menu_commands=("cmd1" "cmd2" "cmd3" "cmd4" "cmd5")
        
        echo "Launching fzf search..."
        local result
        result=$(fzf_search_scripts)
        
        if [[ -n "$result" ]]; then
            echo "Selected index: $result"
            echo "Selected option: ${menu_options[$result]}"
        else
            echo "Search cancelled"
        fi
        
    else
        echo "fzf not available. Install with: sudo apt install fzf"
    fi
    
    echo ""
    echo "fzf demo complete!"
    echo ""
}

# =============================================================================
# Main Demo Menu
# =============================================================================

show_demo_menu() {
    while true; do
        clear
        print_banner "BASHMENU UI/UX DEMO" "neon"
        echo ""
        echo "Select a demo to run:"
        echo ""
        echo "  1. Spinner Animations"
        echo "  2. Progress Bars"
        echo "  3. Gradient Text"
        echo "  4. Banners"
        echo "  5. In-Terminal Notifications"
        echo "  6. Terminal Notification Banners"
        echo "  7. Desktop Notifications"
        echo "  8. Dialog/Whiptail"
        echo "  9. fzf Search"
        echo "  a. Run All Demos"
        echo "  q. Quit"
        echo ""
        echo -n "Choice: "
        
        read -n1 choice
        echo ""
        echo ""
        
        case $choice in
            1) demo_spinners ;;
            2) demo_progress_bars ;;
            3) demo_gradients ;;
            4) demo_banners ;;
            5) demo_notifications ;;
            6) demo_terminal_notifications ;;
            7) demo_desktop_notifications ;;
            8) demo_dialog ;;
            9) demo_fzf ;;
            a|A)
                demo_spinners
                demo_progress_bars
                demo_gradients
                demo_banners
                demo_notifications
                demo_terminal_notifications
                demo_desktop_notifications
                demo_dialog
                demo_fzf
                ;;
            q|Q) 
                echo "Exiting demo..."
                exit 0
                ;;
            *)
                echo "Invalid choice"
                ;;
        esac
        
        echo ""
        echo "Press any key to continue..."
        read -n1 -s
    done
}

# =============================================================================
# Main
# =============================================================================

echo "Initializing Bashmenu UI/UX Demo..."
echo ""

# Show demo menu
show_demo_menu
