#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Menu Loop - Bashmenu
# =============================================================================
# Description: Main menu loop orchestration
# Version:     3.0
# Author:      JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Main Menu Loop
# =============================================================================

# menu_loop() -> void
# Main menu loop - determines mode and delegates to appropriate handler
menu_loop() {
    # Determine if using hierarchical mode
    local use_hierarchical=false
    if [[ "${ENABLE_AUTO_SCAN:-true}" == "true" ]]; then
        # Only check AUTO_SCRIPTS if auto-scan is enabled
        if declare -p AUTO_SCRIPTS >/dev/null 2>&1 && [[ ${#AUTO_SCRIPTS[@]} -gt 0 ]]; then
            use_hierarchical=true
            if declare -f log_info >/dev/null; then
                log_info "Using hierarchical menu mode"
            fi
        else
            # No scripts found, show message and exit
            show_no_scripts_message
            return
        fi
    fi

    if [[ "$use_hierarchical" == "true" ]]; then
        menu_loop_hierarchical
    else
        menu_loop_classic
    fi
}

# =============================================================================
# Classic Menu Loop
# =============================================================================

# menu_loop_classic() -> void
# Menu loop for classic mode (manual scripts)
menu_loop_classic() {
    local selected_index=0
    local max_selection=${#menu_options[@]}

    while true; do
        # Display menu
        if declare -f refresh_menu_display >/dev/null; then
            refresh_menu_display "classic" "$selected_index"
        else
            display_header
            display_menu "$selected_index"
            display_footer
        fi

        # Get user input
        local choice
        choice=$(read_input)

        # Handle input
        if ! handle_classic_menu_input "$choice" "$selected_index" "$max_selection"; then
            break
        fi
        
        # Update selected_index if it was modified
        selected_index=$?
    done
}

# handle_classic_menu_input() -> int
# Handle input for classic menu
# Args:
#   $1 - User choice
#   $2 - Current selected index
#   $3 - Maximum selection
# Returns: New selected index or 0 to break loop
handle_classic_menu_input() {
    local choice="$1"
    local selected_index="$2"
    local max_selection="$3"

    case $choice in
        "timeout")
            return "$selected_index"
            ;;
        "q"|"Q"|"quit"|"exit")
            exit_menu
            return 0
            ;;
        "d"|"D")
            if declare -f cmd_dashboard >/dev/null; then
                cmd_dashboard
            fi
            return "$selected_index"
            ;;
        "s"|"S")
            if declare -f cmd_quick_status >/dev/null; then
                cmd_quick_status
            fi
            return "$selected_index"
            ;;
        "/")
            handle_search_command "$selected_index"
            return $?
            ;;
        "?")
            show_help_screen
            return "$selected_index"
            ;;
        "r"|"R")
            return "$selected_index"
            ;;
        "ENTER")
            execute_menu_item "$selected_index"
            return "$selected_index"
            ;;
        "UP"|"DOWN"|"HOME"|"END")
            local new_index
            new_index=$(handle_keyboard_input "$choice" "$selected_index" "$max_selection")
            return "$new_index"
            ;;
        *)
            # Ignore unknown input
            return "$selected_index"
            ;;
    esac
}

# =============================================================================
# Hierarchical Menu Loop
# =============================================================================

# menu_loop_hierarchical() -> void
# Menu loop for hierarchical mode (auto-detected)
menu_loop_hierarchical() {
    local selected_index=0

    while true; do
        # Generate menu based on current directory
        local current_dir=$(get_current_path_string)
        generate_directory_menu "$current_dir"

        local max_selection=${#menu_options[@]}

        # If no options, show message and go back
        if [[ $max_selection -eq 0 ]]; then
            show_empty_directory_message
            handle_navigation "navigate_up"
            continue
        fi

        # Display menu with breadcrumb
        display_header
        display_menu "$selected_index"
        display_footer

        # Get user input
        local choice
        choice=$(read_input)

        # Handle input
        if ! handle_hierarchical_menu_input "$choice" "$selected_index" "$max_selection"; then
            break
        fi
        
        # Update selected_index if it was modified
        selected_index=$?
    done
}

# handle_hierarchical_menu_input() -> int
# Handle input for hierarchical menu
# Args:
#   $1 - User choice
#   $2 - Current selected index
#   $3 - Maximum selection
# Returns: New selected index or 0 to break loop
handle_hierarchical_menu_input() {
    local choice="$1"
    local selected_index="$2"
    local max_selection="$3"

    case $choice in
        "timeout")
            return "$selected_index"
            ;;
        "q"|"Q"|"quit"|"exit")
            exit_menu
            return 0
            ;;
        "d"|"D")
            if declare -f cmd_dashboard >/dev/null; then
                cmd_dashboard
            fi
            return "$selected_index"
            ;;
        "s"|"S")
            if declare -f cmd_quick_status >/dev/null; then
                cmd_quick_status
            fi
            return "$selected_index"
            ;;
        "/")
            handle_search_command "$selected_index"
            return $?
            ;;
        "?")
            show_help_screen
            return "$selected_index"
            ;;
        "r"|"R"|"refresh")
            return "$selected_index"
            ;;
        "ENTER")
            local command="${menu_commands[$selected_index]}"
            handle_menu_command "$command"
            return "$selected_index"
            ;;
        "UP"|"DOWN"|"HOME"|"END")
            local new_index
            new_index=$(handle_keyboard_input "$choice" "$selected_index" "$max_selection")
            return "$new_index"
            ;;
        *)
            # Ignore unknown input
            return "$selected_index"
            ;;
    esac
}

# =============================================================================
# Command Handlers
# =============================================================================

# handle_menu_command() -> void
# Handle menu command execution
# Args:
#   $1 - Command to execute
handle_menu_command() {
    local command="$1"

    if [[ "$command" =~ ^execute_script: ]]; then
        # Execute script directly
        local script_path="${command#execute_script:}"
        execute_external_script "$script_path"
        echo ""
        echo -e "${info_color}Press Enter to continue...${NC}"
        read -s
    elif [[ "$command" =~ ^execute_auto: ]]; then
        # Execute auto-detected script
        handle_navigation "$command"
    else
        # Handle navigation commands
        handle_navigation "$command"
    fi
}

# handle_search_command() -> int
# Handle search command
# Args:
#   $1 - Current selected index
# Returns: Selected index (possibly updated)
handle_search_command() {
    local selected_index="$1"

    if declare -f fzf_search_scripts >/dev/null && [[ "${ENABLE_FZF_SEARCH:-true}" == "true" ]]; then
        local search_result
        search_result=$(fzf_search_scripts)
        if [[ -n "$search_result" ]]; then
            selected_index="$search_result"
            local command="${menu_commands[$selected_index]}"
            if [[ "$command" =~ ^(navigate|execute) ]]; then
                handle_navigation "$command"
            fi
        fi
    else
        show_info_banner "Search requires fzf (install with: sudo apt install fzf)" 3
    fi

    return "$selected_index"
}

# =============================================================================
# Helper Functions
# =============================================================================

# show_empty_directory_message() -> void
# Show message when directory is empty
show_empty_directory_message() {
    clear_screen
    display_header
    echo ""
    echo -e "${warning_color}No items found in this directory${NC}"
    echo ""
    echo -e "${success_color}Press Enter to go back...${NC}"
    read -s
}

# show_no_scripts_message() -> void
# Show message when no scripts are found
show_no_scripts_message() {
    clear_screen
    display_header
    echo ""
    echo -e "${warning_color}No scripts found in plugin directories${NC}"
    echo ""
    echo -e "${info_color}Project location: ${PROJECT_ROOT:-$(pwd)}${NC}"
    echo ""
    echo -e "${info_color}To add scripts:${NC}"
    echo "1. Place executable scripts in: ./plugins/"
    echo "2. Or configure manually in: ./config/scripts.conf"
    echo ""
    echo -e "${success_color}Press any key to exit...${NC}"
    read -s -n1
    exit_menu
}

# =============================================================================
# Export Functions
# =============================================================================

export -f menu_loop
export -f menu_loop_classic
export -f menu_loop_hierarchical
