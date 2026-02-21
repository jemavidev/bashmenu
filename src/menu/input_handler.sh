#!/bin/bash

# =============================================================================
# Menu Input Handler Module for Bashmenu
# =============================================================================
# Description: Extracted input handling logic from menu_loop functions
# Version:     1.0
# =============================================================================

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Input Handling Functions
# =============================================================================

# Handle user input for classic menu
handle_classic_input() {
    local choice="$1"
    local -n selected_index_ref=$2
    local max_selection=$3
    
    case $choice in
        "timeout")
            # Silent timeout - no message, just refresh
            return 0
            ;;
        "q"|"Q"|"quit"|"exit")
            exit_menu
            return 1
            ;;
        "d"|"D")
            # Dashboard
            if declare -f cmd_dashboard >/dev/null; then
                cmd_dashboard
            fi
            return 0
            ;;
        "s"|"S")
            # System status
            if declare -f cmd_system_status >/dev/null; then
                cmd_system_status
            fi
            return 0
            ;;
        "r"|"R")
            # Refresh menu
            if declare -f log_info >/dev/null; then
                log_info "Refreshing menu..."
            fi
            return 0
            ;;
        "up"|"UP")
            ((selected_index_ref--))
            if [[ $selected_index_ref -lt 0 ]]; then
                selected_index_ref=$((max_selection - 1))
            fi
            return 0
            ;;
        "down"|"DOWN")
            ((selected_index_ref++))
            if [[ $selected_index_ref -ge $max_selection ]]; then
                selected_index_ref=0
            fi
            return 0
            ;;
        "page_up"|"PAGE_UP")
            selected_index_ref=$((selected_index_ref - 10))
            if [[ $selected_index_ref -lt 0 ]]; then
                selected_index_ref=0
            fi
            return 0
            ;;
        "page_down"|"PAGE_DOWN")
            selected_index_ref=$((selected_index_ref + 10))
            if [[ $selected_index_ref -ge $max_selection ]]; then
                selected_index_ref=$((max_selection - 1))
            fi
            return 0
            ;;
        "home"|"HOME")
            selected_index_ref=0
            return 0
            ;;
        "end"|"END")
            selected_index_ref=$((max_selection - 1))
            return 0
            ;;
        *)
            # Check if it's a number (menu selection)
            if [[ "$choice" =~ ^[0-9]+$ ]]; then
                local num_choice=$((choice - 1))
                if [[ $num_choice -ge 0 && $num_choice -lt $max_selection ]]; then
                    execute_menu_option "$num_choice"
                    return 0
                else
                    if declare -f log_error >/dev/null; then
                        log_error "Invalid selection: $choice"
                    fi
                    return 0
                fi
            else
                if declare -f log_error >/dev/null; then
                    log_error "Unknown command: $choice"
                fi
                return 0
            fi
            ;;
    esac
}

# Handle user input for hierarchical menu
handle_hierarchical_input() {
    local choice="$1"
    local -n selected_index_ref=$2
    local max_selection=$3
    
    case $choice in
        "timeout")
            # Silent timeout - no message, just refresh
            return 0
            ;;
        "q"|"Q"|"quit"|"exit")
            exit_menu
            return 1
            ;;
        "b"|"B"|"back"|".."|".")
            # Navigate back to parent directory
            if declare -f navigate_back >/dev/null; then
                navigate_back
            fi
            return 0
            ;;
        "d"|"D")
            # Dashboard
            if declare -f cmd_dashboard >/dev/null; then
                cmd_dashboard
            fi
            return 0
            ;;
        "s"|"S")
            # System status
            if declare -f cmd_system_status >/dev/null; then
                cmd_system_status
            fi
            return 0
            ;;
        "r"|"R")
            # Refresh menu
            if declare -f log_info >/dev/null; then
                log_info "Refreshing menu..."
            fi
            return 0
            ;;
        "up"|"UP")
            ((selected_index_ref--))
            if [[ $selected_index_ref -lt 0 ]]; then
                selected_index_ref=$((max_selection - 1))
            fi
            return 0
            ;;
        "down"|"DOWN")
            ((selected_index_ref++))
            if [[ $selected_index_ref -ge $max_selection ]]; then
                selected_index_ref=0
            fi
            return 0
            ;;
        "page_up"|"PAGE_UP")
            selected_index_ref=$((selected_index_ref - 10))
            if [[ $selected_index_ref -lt 0 ]]; then
                selected_index_ref=0
            fi
            return 0
            ;;
        "page_down"|"PAGE_DOWN")
            selected_index_ref=$((selected_index_ref + 10))
            if [[ $selected_index_ref -ge $max_selection ]]; then
                selected_index_ref=$((max_selection - 1))
            fi
            return 0
            ;;
        "home"|"HOME")
            selected_index_ref=0
            return 0
            ;;
        "end"|"END")
            selected_index_ref=$((max_selection - 1))
            return 0
            ;;
        *)
            # Check if it's a number (menu selection)
            if [[ "$choice" =~ ^[0-9]+$ ]]; then
                local num_choice=$((choice - 1))
                if [[ $num_choice -ge 0 && $num_choice -lt $max_selection ]]; then
                    execute_hierarchical_selection "$num_choice"
                    return 0
                else
                    if declare -f log_error >/dev/null; then
                        log_error "Invalid selection: $choice"
                    fi
                    return 0
                fi
            else
                if declare -f log_error >/dev/null; then
                    log_error "Unknown command: $choice"
                fi
                return 0
            fi
            ;;
    esac
}

# Execute menu option for classic menu
execute_menu_option() {
    local selection_index=$1
    
    if [[ $selection_index -lt 0 || $selection_index -ge ${#menu_options[@]} ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Invalid menu selection: $selection_index"
        fi
        return 1
    fi
    
    local option="${menu_options[$selection_index]}"
    
    # Check if it's a function
    if declare -f "$option" >/dev/null; then
        "$option"
    elif [[ -n "${option:-}" && -x "$option" ]]; then
        # It's an executable script
        execute_external_script "$option"
    else
        if declare -f log_error >/dev/null; then
            log_error "Cannot execute option: $option"
        fi
    fi
}

# Execute selection for hierarchical menu
execute_hierarchical_selection() {
    local selection_index=$1
    
    if [[ $selection_index -lt 0 || $selection_index -ge ${#menu_items[@]} ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Invalid menu selection: $selection_index"
        fi
        return 1
    fi
    
    local item="${menu_items[$selection_index]}"
    
    # Get item type from menu_hierarchy
    local current_path="${CURRENT_PATH:-/}"
    local item_type="${menu_hierarchy[$current_path/$item]:-unknown}"
    
    case "$item_type" in
        "directory")
            # Navigate into directory
            if declare -f navigate_into_directory >/dev/null; then
                navigate_into_directory "$item"
            fi
            ;;
        "script")
            # Execute script
            if declare -f execute_auto_script >/dev/null; then
                execute_auto_script "$item"
            fi
            ;;
        *)
            if declare -f log_error >/dev/null; then
                log_error "Unknown item type: $item_type for item: $item"
            fi
            ;;
    esac
}

# Export functions
export -f handle_classic_input
export -f handle_hierarchical_input
export -f execute_menu_option
export -f execute_hierarchical_selection