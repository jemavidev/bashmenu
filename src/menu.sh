#!/bin/bash

# =============================================================================
# Bashmenu Menu System
# =============================================================================

# Source utilities and commands
source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/commands.sh"

# =============================================================================
# Menu Configuration
# =============================================================================

# Default menu options
declare -a menu_options
declare -a menu_commands
declare -a menu_descriptions
declare -a menu_levels

# Initialize menu from configuration
initialize_menu() {
    # Clear arrays
    menu_options=()
    menu_commands=()
    menu_descriptions=()
    menu_levels=()
    
    # Add default commands
    add_menu_item "System Information" "cmd_system_info" "Show detailed system information" 1
    add_menu_item "Disk Usage" "cmd_disk_usage" "Show disk space usage" 1
    add_menu_item "Memory Usage" "cmd_memory_usage" "Show memory usage" 1
    add_menu_item "Running Processes" "cmd_running_processes" "Show top running processes" 1
    add_menu_item "Network Status" "cmd_network_status" "Show network connections" 2
    add_menu_item "System Load" "cmd_system_load" "Show system load" 1
    add_menu_item "User Management" "cmd_user_management" "Show logged users" 1
    add_menu_item "Package Updates" "cmd_package_updates" "Show available updates" 2
    add_menu_item "System Monitoring" "cmd_monitor_system" "Monitor system resources" 1
    add_menu_item "System Maintenance" "cmd_system_maintenance" "Run maintenance tasks" 2
    add_menu_item "Show Help" "cmd_show_help" "Display help information" 1
    add_menu_item "Exit" "exit_menu" "Exit the menu" 1
}

# Add menu item
add_menu_item() {
    local display_name="$1"
    local command="$2"
    local description="$3"
    local level="${4:-1}"
    
    menu_options+=("$display_name")
    menu_commands+=("$command")
    menu_descriptions+=("$description")
    menu_levels+=("$level")
}

# =============================================================================
# Theme System
# =============================================================================

# Declare theme variables as global
declare -g default_frame_top default_frame_bottom default_frame_left default_frame_right
declare -g default_title_color default_option_color default_selected_color default_error_color default_success_color default_warning_color
declare -g dark_frame_top dark_frame_bottom dark_frame_left dark_frame_right
declare -g dark_title_color dark_option_color dark_selected_color dark_error_color dark_success_color dark_warning_color
declare -g colorful_frame_top colorful_frame_bottom colorful_frame_left colorful_frame_right
declare -g colorful_title_color colorful_option_color colorful_selected_color colorful_error_color colorful_success_color colorful_warning_color
declare -g minimal_frame_top minimal_frame_bottom minimal_frame_left minimal_frame_right
declare -g minimal_title_color minimal_option_color minimal_selected_color minimal_error_color minimal_success_color minimal_warning_color

# Initialize themes using simple variables instead of associative arrays
initialize_themes() {
    # Default theme
    export default_frame_top="╭───────────────────────────────────────────────╮"
    export default_frame_bottom="╰───────────────────────────────────────────────╯"
    export default_frame_left="│"
    export default_frame_right="│"
    export default_title_color="\033[1;36m"
    export default_option_color="\033[0m"
    export default_selected_color="\033[1;32m"
    export default_error_color="\033[1;31m"
    export default_success_color="\033[1;32m"
    export default_warning_color="\033[1;33m"

    # Dark theme
    export dark_frame_top="┌───────────────────────────────────────────────┐"
    export dark_frame_bottom="└───────────────────────────────────────────────┘"
    export dark_frame_left="│"
    export dark_frame_right="│"
    export dark_title_color="\033[1;35m"
    export dark_option_color="\033[0;37m"
    export dark_selected_color="\033[1;33m"
    export dark_error_color="\033[1;31m"
    export dark_success_color="\033[1;32m"
    export dark_warning_color="\033[1;33m"

    # Colorful theme
    export colorful_frame_top="╔═══════════════════════════════════════════════╗"
    export colorful_frame_bottom="╚═══════════════════════════════════════════════╝"
    export colorful_frame_left="║"
    export colorful_frame_right="║"
    export colorful_title_color="\033[1;31m"
    export colorful_option_color="\033[0;36m"
    export colorful_selected_color="\033[1;33m"
    export colorful_error_color="\033[1;31m"
    export colorful_success_color="\033[1;32m"
    export colorful_warning_color="\033[1;33m"

    # Minimal theme
    export minimal_frame_top=""
    export minimal_frame_bottom=""
    export minimal_frame_left=""
    export minimal_frame_right=""
    export minimal_title_color="\033[1m"
    export minimal_option_color="\033[0m"
    export minimal_selected_color="\033[1;32m"
    export minimal_error_color="\033[1;31m"
    export minimal_success_color="\033[1;32m"
    export minimal_warning_color="\033[1;33m"
}

# Load theme
load_theme() {
    local theme_name="${1:-default}"
    
    # Set theme variables using indirect expansion
    frame_top="${theme_name}_frame_top"
    frame_bottom="${theme_name}_frame_bottom"
    frame_left="${theme_name}_frame_left"
    frame_right="${theme_name}_frame_right"
    title_color="${theme_name}_title_color"
    option_color="${theme_name}_option_color"
    selected_color="${theme_name}_selected_color"
    error_color="${theme_name}_error_color"
    success_color="${theme_name}_success_color"
    warning_color="${theme_name}_warning_color"
    
    # Use indirect expansion to get the actual values
    frame_top="${!frame_top}"
    frame_bottom="${!frame_bottom}"
    frame_left="${!frame_left}"
    frame_right="${!frame_right}"
    title_color="${!title_color}"
    option_color="${!option_color}"
    selected_color="${!selected_color}"
    error_color="${!error_color}"
    success_color="${!success_color}"
    warning_color="${!warning_color}"
    
    # Use default if theme not found, but solo una vez
    if [[ -z "$frame_top" && "$theme_name" != "default" ]]; then
        log_warn "Theme not found: $theme_name, using default"
        load_theme "default"
        return
    elif [[ -z "$frame_top" && "$theme_name" == "default" ]]; then
        log_error "Default theme not found. Menu cannot be displayed."
        exit 1
    else
        log_info "Theme loaded: $theme_name"
    fi
}

# =============================================================================
# Display Functions
# =============================================================================

# Display menu header
display_header() {
    local title="${MENU_TITLE:-Bashmenu}"
    local timestamp=""
    
    if [[ "${SHOW_TIMESTAMP:-true}" == "true" ]]; then
        timestamp=" [$(date '+%H:%M:%S')]"
    fi
    
    clear
    
    if [[ -n "$frame_top" ]]; then
        echo -e "$frame_top"
    fi
    
    if [[ -n "$frame_left" && -n "$frame_right" ]]; then
        local width=49
        local title_with_timestamp="$title$timestamp"
        local padding=$(( (width - ${#title_with_timestamp}) / 2 ))
        
        printf "%s %${padding}s%s%${padding}s %s\n" \
            "$frame_left" "" "$title_with_timestamp" "" "$frame_right"
    else
        echo -e "${title_color}$title$timestamp${NC}"
    fi
    
    if [[ -n "$frame_bottom" ]]; then
        echo -e "$frame_bottom"
    fi
    
    echo ""
}

# Display menu options
display_menu() {
    local selected_index="${1:-0}"
    
    for i in "${!menu_options[@]}"; do
        local option="${menu_options[$i]}"
        local description="${menu_descriptions[$i]}"
        local level="${menu_levels[$i]}"
        
        # Check if user has permission
        local user_level=$(get_user_level)
        local can_execute=true
        
        if [[ "${ENABLE_PERMISSIONS:-false}" == "true" && $user_level -lt $level ]]; then
            can_execute=false
        fi
        
        # Format option number
        local option_num="$((i+1))."
        
        # Choose color based on selection and permissions
        local color="$option_color"
        if [[ $i -eq $selected_index ]]; then
            color="$selected_color"
        fi
        
        if [[ "$can_execute" == "false" ]]; then
            color="$warning_color"
            option_num="$option_num [LOCKED]"
        fi
        
        # Display option
        echo -e "$color$option_num $option${NC}"
        if [[ -n "$description" ]]; then
            echo "    $description"
        fi
    done
}

# Display footer
display_footer() {
    echo ""
    if [[ -n "$frame_top" ]]; then
        echo -e "$frame_top"
    fi
    
    if [[ -n "$frame_left" && -n "$frame_right" ]]; then
        printf "%s %-47s %s\n" "$frame_left" "Use arrow keys or numbers to navigate" "$frame_right"
    else
        echo "Use arrow keys or numbers to navigate"
    fi
    
    if [[ -n "$frame_bottom" ]]; then
        echo -e "$frame_bottom"
    fi
}

# =============================================================================
# Input Handling
# =============================================================================

# Read user input with timeout
read_input() {
    local timeout="${1:-30}"
    local choice=""
    
    # Try to read with timeout
    if read -t "$timeout" -p "Enter your choice: " choice; then
        echo "$choice"
    else
        echo "timeout"
    fi
}

# Handle keyboard input
handle_keyboard_input() {
    local key="$1"
    local current_selection="$2"
    local max_selection="$3"
    
    case $key in
        "UP"|"k")
            if [[ $current_selection -gt 0 ]]; then
                echo $((current_selection - 1))
            else
                echo $((max_selection - 1))
            fi
            ;;
        "DOWN"|"j")
            if [[ $current_selection -lt $((max_selection - 1)) ]]; then
                echo $((current_selection + 1))
            else
                echo 0
            fi
            ;;
        "HOME"|"g")
            echo 0
            ;;
        "END"|"G")
            echo $((max_selection - 1))
            ;;
        *)
            echo "$current_selection"
            ;;
    esac
}

# Validate numeric input
validate_numeric_input() {
    local input="$1"
    local max_value="$2"
    
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        if [[ $input -ge 1 && $input -le $max_value ]]; then
            return 0
        fi
    fi
    return 1
}

# =============================================================================
# Menu Navigation
# =============================================================================

# Main menu loop
menu_loop() {
    local selected_index=0
    local max_selection=${#menu_options[@]}
    
    # Load plugins
    load_plugins
    
    while true; do
        # Display menu
        display_header
        display_menu "$selected_index"
        display_footer
        
        # Get user input
        local choice
        choice=$(read_input)
        
        # Handle special cases
        case $choice in
            "timeout")
                echo -e "\n${warning_color}Session timeout. Refreshing...${NC}"
                sleep 2
                continue
                ;;
            "q"|"Q"|"quit"|"exit")
                exit_menu
                ;;
            "h"|"H"|"help")
                cmd_show_help
                echo -e "\n${success_color}Press Enter to continue...${NC}"
                read -s
                continue
                ;;
            "r"|"R"|"refresh")
                log_info "Menu refreshed"
                continue
                ;;
            "")
                # No input, continue
                continue
                ;;
        esac
        
        # Handle numeric input
        if validate_numeric_input "$choice" "$max_selection"; then
            selected_index=$((choice - 1))
            execute_menu_item "$selected_index"
        else
            # Handle arrow keys
            local new_selection
            new_selection=$(handle_keyboard_input "$choice" "$selected_index" "$max_selection")
            
            if [[ $new_selection -ne $selected_index ]]; then
                selected_index=$new_selection
            else
                echo -e "\n${error_color}Invalid choice: $choice${NC}"
                echo -e "${error_color}Please enter a number between 1 and $max_selection${NC}"
                sleep 2
            fi
        fi
        
        # Wait for user to continue
        if [[ "${AUTO_REFRESH:-false}" != "true" ]]; then
            echo -e "\n${success_color}Press Enter to continue...${NC}"
            read -s
        fi
    done
}

# Execute menu item
execute_menu_item() {
    local index="$1"
    
    if [[ $index -ge 0 && $index -lt ${#menu_options[@]} ]]; then
        local command="${menu_commands[$index]}"
        local option_name="${menu_options[$index]}"
        local level="${menu_levels[$index]}"
        
        # Check permissions
        if [[ "${ENABLE_PERMISSIONS:-false}" == "true" ]]; then
            local user_level=$(get_user_level)
            if [[ $user_level -lt $level ]]; then
                print_error "Access denied: $option_name requires level $level (you have level $user_level)"
                return 1
            fi
        fi
        
        # Execute command
        if [[ "$command" == "exit_menu" ]]; then
            exit_menu
        else
            # Execute the command function
            if declare -f "$command" > /dev/null; then
                $command
            else
                print_error "Command not found: $command"
            fi
        fi
    else
        print_error "Invalid menu index: $index"
    fi
}

# Exit menu
exit_menu() {
    echo ""
    echo -e "${success_color}Exiting Bashmenu. Goodbye!${NC}"
    echo ""
    
    # Cleanup
    cleanup_old_backups
    
    log_info "Bashmenu exited"
    exit 0
}

# =============================================================================
# Search and Filter
# =============================================================================

# Search menu items
search_menu() {
    local search_term="$1"
    local filtered_indices=()
    
    for i in "${!menu_options[@]}"; do
        local option="${menu_options[$i]}"
        local description="${menu_descriptions[$i]}"
        
        if [[ $option =~ $search_term || $description =~ $search_term ]]; then
            filtered_indices+=("$i")
        fi
    done
    
    echo "${filtered_indices[@]}"
}

# Display filtered menu
display_filtered_menu() {
    local filtered_indices=("$@")
    local selected_index=0
    
    while true; do
        clear
        print_header "Search Results"
        
        if [[ ${#filtered_indices[@]} -eq 0 ]]; then
            print_warning "No items found matching your search"
            echo -e "\n${success_color}Press Enter to return to main menu...${NC}"
            read -s
            return
        fi
        
        # Display filtered options
        for i in "${!filtered_indices[@]}"; do
            local original_index="${filtered_indices[$i]}"
            local option="${menu_options[$original_index]}"
            local description="${menu_descriptions[$original_index]}"
            
            local color="$option_color"
            if [[ $i -eq $selected_index ]]; then
                color="$selected_color"
            fi
            
            echo -e "$color$((i+1)). $option${NC}"
            if [[ -n "$description" ]]; then
                echo "    $description"
            fi
        done
        
        echo ""
        echo "Press Enter to select, 'q' to quit search"
        
        # Get user input
        read -p "Choice: " choice
        
        case $choice in
            "q"|"Q") return ;;
            "")
                if [[ $selected_index -ge 0 && $selected_index -lt ${#filtered_indices[@]} ]]; then
                    local original_index="${filtered_indices[$selected_index]}"
                    execute_menu_item "$original_index"
                fi
                ;;
            *)
                if validate_numeric_input "$choice" "${#filtered_indices[@]}"; then
                    selected_index=$((choice - 1))
                    local original_index="${filtered_indices[$selected_index]}"
                    execute_menu_item "$original_index"
                fi
                ;;
        esac
    done
}

# =============================================================================
# Export Functions
# =============================================================================

export -f initialize_menu
export -f add_menu_item
export -f load_theme
export -f display_header
export -f display_menu
export -f display_footer
export -f read_input
export -f handle_keyboard_input
export -f validate_numeric_input
export -f menu_loop
export -f execute_menu_item
export -f exit_menu
export -f search_menu
export -f display_filtered_menu
export -f initialize_themes

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

# Initialize themes when this file is sourced
initialize_themes 