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

    if declare -f log_info >/dev/null; then
        log_info "Initializing menu system"
    fi

    # Load external scripts from configuration
    local external_scripts_loaded=false
    load_external_scripts
    
    # Check if external scripts were loaded
    if [[ ${#menu_options[@]} -gt 0 ]]; then
        external_scripts_loaded=true
        if declare -f log_info >/dev/null; then
            log_info "External scripts loaded, skipping plugin loading"
        fi
    fi

    # Add only the 5 basic commands
    add_menu_item "List Files (ls)" "cmd_list_files" "Show files in current directory" 1
    add_menu_item "List Detailed (ll)" "cmd_list_detailed" "Detailed file listing" 1
    add_menu_item "Disk Space (df)" "cmd_disk_free" "Show disk usage" 1
    add_menu_item "Memory (free)" "cmd_memory_free" "Show memory usage" 1
    add_menu_item "Processes (ps)" "cmd_process_list" "Show running processes" 1
    
    # Always add Exit as the last option
    add_menu_item "Exit" "exit_menu" "Exit the menu" 1
    
    if declare -f log_info >/dev/null; then
        log_info "Menu initialized with ${#menu_options[@]} items"
    fi
}

# Add menu item with duplicate prevention
add_menu_item() {
    local display_name="$1"
    local command="$2"
    local description="$3"
    local level="${4:-1}"
    
    # Check for duplicate commands
    for i in "${!menu_commands[@]}"; do
        if [[ "${menu_commands[$i]}" == "$command" ]]; then
            # Command already exists, skip adding
            if declare -f log_debug >/dev/null; then
                log_debug "Menu item already exists, skipping: $display_name ($command)"
            fi
            return 1
        fi
    done
    
    # Check for duplicate display names
    for i in "${!menu_options[@]}"; do
        if [[ "${menu_options[$i]}" == "$display_name" ]]; then
            # Display name already exists, skip adding
            if declare -f log_debug >/dev/null; then
                log_debug "Menu item with same name already exists, skipping: $display_name"
            fi
            return 1
        fi
    done
    
    # Add the menu item
    menu_options+=("$display_name")
    menu_commands+=("$command")
    menu_descriptions+=("$description")
    menu_levels+=("$level")
    
    if declare -f log_debug >/dev/null; then
        log_debug "Menu item added: $display_name ($command)"
    fi
    
    return 0
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
    # Default theme - Simple ASCII with dashes
    export default_frame_top="--------------------------------------------------"
    export default_frame_bottom="--------------------------------------------------"
    export default_frame_left=""
    export default_frame_right=""
    export default_title_color="\033[1;36m"
    export default_option_color="\033[0;37m"
    export default_selected_color="\033[1;32m"
    export default_error_color="\033[1;31m"
    export default_success_color="\033[1;32m"
    export default_warning_color="\033[1;33m"
    export default_info_color="\033[0;34m"

    # Dark theme - Dashes with purple
    export dark_frame_top="--------------------------------------------------"
    export dark_frame_bottom="--------------------------------------------------"
    export dark_frame_left=""
    export dark_frame_right=""
    export dark_title_color="\033[1;35m"
    export dark_option_color="\033[0;37m"
    export dark_selected_color="\033[1;33m"
    export dark_error_color="\033[1;31m"
    export dark_success_color="\033[1;32m"
    export dark_warning_color="\033[1;33m"
    export dark_info_color="\033[0;34m"

    # Colorful theme - Dashes with indicator
    export colorful_frame_top="--------------------------------------------------"
    export colorful_frame_bottom="--------------------------------------------------"
    export colorful_frame_left=">"
    export colorful_frame_right=""
    export colorful_title_color="\033[1;31m"
    export colorful_option_color="\033[0;36m"
    export colorful_selected_color="\033[1;33m"
    export colorful_error_color="\033[1;31m"
    export colorful_success_color="\033[1;32m"
    export colorful_warning_color="\033[1;33m"
    export colorful_info_color="\033[0;34m"

    # Minimal theme - Clean and simple (no frames)
    export minimal_frame_top=""
    export minimal_frame_bottom=""
    export minimal_frame_left=""
    export minimal_frame_right=""
    export minimal_title_color="\033[1;37m"
    export minimal_option_color="\033[0;37m"
    export minimal_selected_color="\033[1;32m"
    export minimal_error_color="\033[1;31m"
    export minimal_success_color="\033[1;32m"
    export minimal_warning_color="\033[1;33m"
    export minimal_info_color="\033[0;34m"

    # Modern theme - Dashes for compatibility
    export modern_frame_top="--------------------------------------------------"
    export modern_frame_bottom="--------------------------------------------------"
    export modern_frame_left=""
    export modern_frame_right=""
    export modern_title_color="\033[1;38;5;51m"
    export modern_option_color="\033[0;38;5;250m"
    export modern_selected_color="\033[1;38;5;46m"
    export modern_error_color="\033[1;38;5;196m"
    export modern_success_color="\033[1;38;5;46m"
    export modern_warning_color="\033[1;38;5;226m"
    export modern_info_color="\033[0;38;5;39m"
}

# Load theme
load_theme() {
    local theme_name="${1:-default}"
    local fallback_attempted="${2:-false}"
    
    if declare -f log_debug >/dev/null; then
        log_debug "Attempting to load theme: $theme_name"
    fi
    
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
    
    # Check if theme loaded successfully
    if [[ -z "$frame_top" ]]; then
        if [[ "$theme_name" != "default" && "$fallback_attempted" == "false" ]]; then
            # Theme not found, try default
            if declare -f log_warn >/dev/null; then
                log_warn "Theme not found: $theme_name, falling back to default theme"
            fi
            print_warning "Theme '$theme_name' not found, using default theme"
            load_theme "default" "true"
            return $?
        else
            # Default theme failed or already attempted fallback
            if declare -f log_error >/dev/null; then
                log_error "Failed to load theme: $theme_name (default theme may be corrupted)"
            fi
            print_error "Critical error: Cannot load theme system"
            print_error "Theme initialization failed. Please check installation."
            return 1
        fi
    fi
    
    # Theme loaded successfully
    if declare -f log_info >/dev/null; then
        log_info "Theme loaded successfully: $theme_name"
    fi
    
    return 0
}

# =============================================================================
# Display Functions
# =============================================================================

# Anti-flickering: Use buffer for display
declare -g DISPLAY_BUFFER=""

# Clear screen with anti-flickering
clear_screen() {
    # Use tput for better control
    if command -v tput >/dev/null 2>&1; then
        tput clear
    else
        clear
    fi
}

# Display menu header
display_header() {
    local title="${MENU_TITLE:-Bashmenu}"
    local timestamp=""

    if [[ "${SHOW_TIMESTAMP:-true}" == "true" ]]; then
        timestamp=" [$(date '+%H:%M:%S')]"
    fi

    clear_screen

    # Standard width for all headers
    local width=50
    local title_with_timestamp="$title$timestamp"
    local title_length=${#title_with_timestamp}
    local padding=$(( (width - title_length) / 2 ))
    local padding_right=$(( width - title_length - padding ))

    # Top frame
    if [[ -n "$frame_top" ]]; then
        echo -e "${title_color}$frame_top${NC}"
    fi

    # Title centered
    if [[ -n "$frame_left" && -n "$frame_right" ]]; then
        printf "${title_color}%s%${padding}s%s%${padding_right}s%s${NC}\n" \
            "$frame_left" "" "$title_with_timestamp" "" "$frame_right"
    else
        printf "${title_color}%${padding}s%s%${padding_right}s${NC}\n" \
            "" "$title_with_timestamp" ""
    fi

    # Bottom frame
    if [[ -n "$frame_bottom" ]]; then
        echo -e "${title_color}$frame_bottom${NC}"
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

        # Format option number with better spacing
        local option_num="$((i+1))"
        local padded_num=$(printf "%2d" "$option_num")

        # Choose color based on selection and permissions
        local color="$option_color"
        local icon="  "

        if [[ $i -eq $selected_index ]]; then
            color="$selected_color"
            icon="▶ "
        fi

        if [[ "$can_execute" == "false" ]]; then
            color="$warning_color"
            icon="🔒 "
        fi

        # Display option with improved formatting - single line
        if [[ -n "$description" ]]; then
            printf "%s %s%-2s " "$frame_left" "$icon" "$padded_num"
            echo -e "${color}$option${NC} ${info_color}($description)${NC}"
        else
            printf "%s %s%-2s " "$frame_left" "$icon" "$padded_num"
            echo -e "${color}$option${NC}"
        fi
    done
}

# Display footer
display_footer() {
    echo ""
    # Enhanced footer with more shortcuts
    echo -e "Navigate: ${selected_color}↑↓${NC} or ${selected_color}1-9${NC} • ${success_color}Enter${NC} select • ${PURPLE}d${NC} dashboard • ${BLUE}h${NC} help • ${error_color}q${NC} quit"
}

# =============================================================================
# Input Handling
# =============================================================================

# Read user input with timeout
read_input() {
    local timeout="${INPUT_TIMEOUT:-30}"
    local choice=""
    
    # Check if timeout is disabled
    if [[ "${SESSION_TIMEOUT_ENABLED:-true}" != "true" ]]; then
        timeout=0  # No timeout
    fi

    # Try to read with timeout - using -n1 for single character, -s for silent
    if [[ $timeout -eq 0 ]]; then
        # No timeout - wait indefinitely
        read -n1 -s choice
    elif read -t "$timeout" -n1 -s choice; then
        # Successfully read with timeout
        :
    else
        # Timeout occurred
        echo "timeout"
        return
    fi
    
    # Handle special keys (arrows)
    case "$choice" in
        $'\e')  # Escape sequence start
            read -t 0.1 -n2 -s rest
            case "$rest" in
                "[A") echo "UP" ;;
                "[B") echo "DOWN" ;;
                "[C") echo "RIGHT" ;;
                "[D") echo "LEFT" ;;
                "[H") echo "HOME" ;;
                "[F") echo "END" ;;
                "") echo "ESC" ;;
                *) echo "$choice$rest" ;;
            esac
            ;;
        "") echo "ENTER" ;;
        *) echo "$choice" ;;
    esac
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
            "ENTER")
                # Enter key pressed - execute selected item
                execute_menu_item "$selected_index"
                ;;
            "h"|"H"|"help")
                cmd_show_help
                echo -e "\n${success_color}Press Enter to continue...${NC}"
                read -s -n1
                continue
                ;;
            "r"|"R"|"refresh")
                log_info "Menu refreshed"
                continue
                ;;
            "d"|"D")
                # Quick dashboard access
                cmd_dashboard
                continue
                ;;
            "s"|"S")
                # Quick status check
                cmd_quick_status
                echo -e "\n${success_color}Press Enter to continue...${NC}"
                read -s -n1
                continue
                ;;
            "")
                # No input, continue
                continue
                ;;
        esac

        # Handle numeric input
        if [[ "$choice" =~ ^[0-9]+$ ]] && validate_numeric_input "$choice" "$max_selection"; then
            selected_index=$((choice - 1))
            execute_menu_item "$selected_index"
            # Wait for user to continue after executing a command
            if [[ "${AUTO_REFRESH:-false}" != "true" ]]; then
                echo -e "\n${success_color}Press Enter to continue...${NC}"
                read -s -n1
            fi
        elif [[ "$choice" == "ENTER" ]]; then
            # Enter key pressed - execute selected item
            execute_menu_item "$selected_index"
            # Wait for user to continue after executing a command
            if [[ "${AUTO_REFRESH:-false}" != "true" ]]; then
                echo -e "\n${success_color}Press Enter to continue...${NC}"
                read -s -n1
            fi
        else
            # Handle arrow keys and other navigation
            local new_selection
            new_selection=$(handle_keyboard_input "$choice" "$selected_index" "$max_selection")

            if [[ $new_selection -ne $selected_index ]]; then
                selected_index=$new_selection
                # Navigation changed - continue to next iteration without waiting
            else
                # Check if it's a valid single character that should be ignored
                if [[ ${#choice} -eq 1 ]] && [[ ! "$choice" =~ ^[0-9]$ ]]; then
                    # Single non-numeric character - ignore silently
                    continue
                else
                    echo -e "\n${error_color}Invalid choice: $choice${NC}"
                    echo -e "${error_color}Please enter a number between 1 and $max_selection${NC}"
                    sleep 2
                fi
            fi
        fi
    done
}

# Load external scripts from configuration
load_external_scripts() {
    # Check if external scripts are defined in config
    if [[ -n "${EXTERNAL_SCRIPTS:-}" ]]; then
        # Parse external scripts (format: "Name|Path|Description|Level")
        while IFS='|' read -r name path desc level; do
            [[ -z "$name" || -z "$path" ]] && continue
            add_menu_item "$name" "$path" "${desc:-Execute script}" "${level:-1}"
        done <<< "$EXTERNAL_SCRIPTS"
    fi
}

# =============================================================================
# External Script Validation
# =============================================================================

# Sanitize script path to prevent directory traversal
sanitize_script_path() {
    local path="$1"
    
    # Remove any ../ or ./ sequences
    path="${path//.\.\//}"
    path="${path//.\//}"
    
    # Remove multiple consecutive slashes
    path="${path//\/\//\/}"
    
    # Remove trailing slash
    path="${path%/}"
    
    echo "$path"
}

# Validate external script path with comprehensive security checks
validate_script_path() {
    local script_path="$1"
    local validation_errors=0
    
    if declare -f log_debug >/dev/null; then
        log_debug "Validating script path: $script_path"
    fi
    
    # Sanitize the path first
    local sanitized_path=$(sanitize_script_path "$script_path")
    
    # Check if path changed after sanitization (potential attack)
    if [[ "$script_path" != "$sanitized_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script path contains suspicious characters: $script_path"
        fi
        print_error "Script path validation failed: suspicious path"
        return 1
    fi
    
    # Check if path is absolute
    if [[ ! "$script_path" =~ ^/ ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script path must be absolute: $script_path"
        fi
        print_error "Script path must be absolute"
        validation_errors=$((validation_errors + 1))
    fi
    
    # Check if path exists
    if [[ ! -e "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script path does not exist: $script_path"
        fi
        print_error "Script file not found: $script_path"
        validation_errors=$((validation_errors + 1))
    fi
    
    # Check if it's a regular file (not a directory or special file)
    if [[ -e "$script_path" ]] && [[ ! -f "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script path is not a regular file: $script_path"
        fi
        print_error "Script path must be a regular file"
        validation_errors=$((validation_errors + 1))
    fi
    
    # Check if file is readable
    if [[ -f "$script_path" ]] && [[ ! -r "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script file is not readable: $script_path"
        fi
        print_error "Script file is not readable"
        validation_errors=$((validation_errors + 1))
    fi
    
    # Check if executable
    if [[ -f "$script_path" ]] && [[ ! -x "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script file is not executable: $script_path"
        fi
        print_error "Script file is not executable: $script_path"
        validation_errors=$((validation_errors + 1))
    fi
    
    # Check if path is a symbolic link (security consideration)
    if [[ -L "$script_path" ]]; then
        if declare -f log_warn >/dev/null; then
            log_warn "Script path is a symbolic link: $script_path"
        fi
        
        # Resolve the symbolic link
        local real_path=$(readlink -f "$script_path" 2>/dev/null)
        if [[ -z "$real_path" ]]; then
            if declare -f log_error >/dev/null; then
                log_error "Failed to resolve symbolic link: $script_path"
            fi
            print_error "Failed to resolve symbolic link"
            validation_errors=$((validation_errors + 1))
        else
            if declare -f log_info >/dev/null; then
                log_info "Symbolic link resolves to: $real_path"
            fi
            # Recursively validate the real path
            script_path="$real_path"
        fi
    fi
    
    # Check if path is within allowed directories (if configured)
    if [[ -n "${ALLOWED_SCRIPT_DIRS:-}" ]]; then
        local is_allowed=false
        local canonical_script_path=$(readlink -f "$script_path" 2>/dev/null || echo "$script_path")
        
        # Parse allowed directories (colon-separated)
        IFS=':' read -ra allowed_dirs <<< "$ALLOWED_SCRIPT_DIRS"
        
        if declare -f log_debug >/dev/null; then
            log_debug "Checking against allowed directories: ${ALLOWED_SCRIPT_DIRS}"
        fi
        
        for dir in "${allowed_dirs[@]}"; do
            # Skip empty entries
            [[ -z "$dir" ]] && continue
            
            # Get canonical path of allowed directory
            local canonical_dir=$(readlink -f "$dir" 2>/dev/null || echo "$dir")
            
            # Check if script is within this directory
            if [[ "$canonical_script_path" == "$canonical_dir"* ]]; then
                is_allowed=true
                if declare -f log_debug >/dev/null; then
                    log_debug "Script is within allowed directory: $canonical_dir"
                fi
                break
            fi
        done
        
        if [[ "$is_allowed" == "false" ]]; then
            if declare -f log_error >/dev/null; then
                log_error "Script path not in allowed directories: $script_path"
            fi
            print_error "Script path not in allowed directories"
            print_info "Allowed directories: ${ALLOWED_SCRIPT_DIRS}"
            validation_errors=$((validation_errors + 1))
        fi
    fi
    
    # Return validation result
    if [[ $validation_errors -gt 0 ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script validation failed with $validation_errors error(s): $script_path"
        fi
        return 1
    fi
    
    if declare -f log_info >/dev/null; then
        log_info "Script validation passed: $script_path"
    fi
    
    return 0
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
                log_warn "Access denied for user $(whoami): $option_name"
                return 1
            fi
        fi

        # Execute command
        if [[ "$command" == "exit_menu" ]]; then
            exit_menu
        elif [[ "$command" =~ ^/ ]]; then
            # Execute external script with validation and error handling
            if validate_script_path "$command"; then
                echo "Executing: $command"
                echo ""
                log_command "$command" "started"
                
                if "$command"; then
                    echo ""
                    print_success "Script completed successfully"
                    log_command "$command" "success"
                else
                    local exit_code=$?
                    echo ""
                    print_error "Script failed with exit code: $exit_code"
                    log_command "$command" "failed (exit code: $exit_code)"
                fi
            else
                print_error "Script validation failed: $command"
                log_error "Script validation failed: $command"
            fi
        else
            # Execute the command function
            if declare -f "$command" > /dev/null; then
                log_command "$command" "started"
                $command
                log_command "$command" "completed"
            else
                print_error "Command not found: $command"
                log_error "Command not found: $command"
            fi
        fi
    else
        print_error "Invalid menu index: $index"
        log_error "Invalid menu index: $index"
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
export -f initialize_themes
export -f validate_script_path
export -f sanitize_script_path
export -f load_external_scripts

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