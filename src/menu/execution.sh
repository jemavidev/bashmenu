#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Menu Execution - Bashmenu
# =============================================================================
# Description: Menu item execution and script running
# Version:     3.0
# Author:      JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Script Execution Functions
# =============================================================================

# execute_menu_item() -> int
# Execute selected menu item
# Args:
#   $1 - Menu item index
# Returns: 0 on success, 1 on failure
execute_menu_item() {
    local index="$1"

    if [[ $index -ge 0 && $index -lt ${#menu_options[@]} ]]; then
        local command="${menu_commands[$index]}"
        local option_name="${menu_options[$index]}"
        local level="${menu_levels[$index]}"

        # Check permissions
        if ! check_execution_permission "$level" "$option_name"; then
            return 1
        fi

        # Execute command based on type
        execute_command "$command" "$option_name"
    else
        print_error "Invalid menu index: $index"
        if declare -f log_error >/dev/null; then
            log_error "Invalid menu index: $index"
        fi
        return 1
    fi
}

# check_execution_permission() -> int
# Check if user has permission to execute
# Args:
#   $1 - Required permission level
#   $2 - Option name
# Returns: 0 if allowed, 1 if denied
check_execution_permission() {
    local level="$1"
    local option_name="$2"

    if [[ "${ENABLE_PERMISSIONS:-false}" == "true" ]]; then
        local user_level=$(get_user_level)
        if [[ $user_level -lt $level ]]; then
            print_error "Access denied: $option_name requires level $level (you have level $user_level)"
            if declare -f log_warn >/dev/null; then
                log_warn "Access denied for user $(whoami): $option_name"
            fi
            return 1
        fi
    fi
    return 0
}

# execute_command() -> int
# Execute command based on type
# Args:
#   $1 - Command to execute
#   $2 - Option name (for logging)
# Returns: Command exit code
execute_command() {
    local command="$1"
    local option_name="$2"

    # Exit menu command
    if [[ "$command" == "exit_menu" ]]; then
        exit_menu
        return 0
    fi

    # External script (starts with /)
    if [[ "$command" =~ ^/ ]]; then
        execute_external_script "$command"
        return $?
    fi

    # Function command
    if declare -f "$command" > /dev/null; then
        execute_function_command "$command"
        return $?
    fi

    # Command not found
    print_error "Command not found: $command"
    if declare -f log_error >/dev/null; then
        log_error "Command not found: $command"
    fi
    return 1
}

# execute_external_script() -> int
# Execute external script with validation
# Args:
#   $1 - Script path
# Returns: Script exit code
execute_external_script() {
    local script_path="$1"

    if validate_script_path "$script_path"; then
        echo "Executing: $script_path"
        echo ""
        
        if declare -f log_command >/dev/null; then
            log_command "$script_path" "started"
        fi
        
        if "$script_path"; then
            echo ""
            print_success "Script completed successfully"
            if declare -f log_command >/dev/null; then
                log_command "$script_path" "success"
            fi
            return 0
        else
            local exit_code=$?
            echo ""
            print_error "Script failed with exit code: $exit_code"
            if declare -f log_command >/dev/null; then
                log_command "$script_path" "failed (exit code: $exit_code)"
            fi
            return $exit_code
        fi
    else
        print_error "Script validation failed: $script_path"
        if declare -f log_error >/dev/null; then
            log_error "Script validation failed: $script_path"
        fi
        return 1
    fi
}

# execute_function_command() -> int
# Execute function command
# Args:
#   $1 - Function name
# Returns: Function exit code
execute_function_command() {
    local command="$1"

    if declare -f log_command >/dev/null; then
        log_command "$command" "started"
    fi
    
    $command
    local exit_code=$?
    
    if declare -f log_command >/dev/null; then
        log_command "$command" "completed"
    fi
    
    return $exit_code
}

# execute_auto_script() -> int
# Execute auto-detected script
# Args:
#   $1 - Script key
# Returns: Script exit code
execute_auto_script() {
    local script_key="$1"

    local script_path="${AUTO_SCRIPTS[${script_key}_path]}"
    local script_name="${AUTO_SCRIPTS[${script_key}_name]}"

    if [[ -n "$script_path" ]]; then
        if declare -f log_info >/dev/null; then
            log_info "Executing auto-detected script: $script_name ($script_path)"
        fi

        # Use existing execution system with error handling
        if declare -f execute_script >/dev/null; then
            if execute_script "$script_path" "$script_name" ""; then
                if declare -f log_info >/dev/null; then
                    log_info "Auto script completed successfully: $script_name"
                fi
                return 0
            else
                local exit_code=$?
                print_error "Script '$script_name' failed with exit code: $exit_code"
                if declare -f log_error >/dev/null; then
                    log_error "Auto script failed: $script_name (exit code: $exit_code)"
                fi
                echo ""
                echo -e "${info_color}Press Enter to continue...${NC}"
                read -s
                return $exit_code
            fi
        else
            print_error "Script executor not available"
            if declare -f log_error >/dev/null; then
                log_error "execute_script function not found for auto script: $script_name"
            fi
            return 1
        fi
    else
        print_error "Script not found in auto-scripts: $script_key"
        if declare -f log_error >/dev/null; then
            log_error "Auto script not found: $script_key"
        fi
        return 1
    fi
}

# =============================================================================
# Script Registration Functions
# =============================================================================

# register_external_scripts() -> int
# Register external scripts as menu entries
# Returns: 0 on success
register_external_scripts() {
    if [[ ${#SCRIPT_ENTRIES[@]} -eq 0 ]]; then
        if declare -f log_debug >/dev/null; then
            log_debug "No external scripts to register (SCRIPT_ENTRIES is empty)"
        fi
        return 0
    fi
    
    if declare -f log_info >/dev/null; then
        log_info "Registering ${#SCRIPT_ENTRIES[@]} external script(s)"
    fi
    
    local registered_count=0
    
    for script_name in "${!SCRIPT_ENTRIES[@]}"; do
        local entry="${SCRIPT_ENTRIES[$script_name]}"
        IFS='|' read -r path desc level params <<< "$entry"
        
        # Create wrapper function for each script
        create_script_wrapper "$script_name" "$path" "$params"
        
        # Add to menu
        local wrapper_func="exec_${script_name//[^a-zA-Z0-9_]/_}"
        if add_menu_item "$script_name" "$wrapper_func" "$desc" "$level"; then
            registered_count=$((registered_count + 1))
            if declare -f log_debug >/dev/null; then
                log_debug "Registered script: $script_name -> $wrapper_func"
            fi
        fi
    done
    
    if declare -f log_info >/dev/null; then
        log_info "Registered $registered_count external script(s) in menu"
    fi
    
    print_success "Registered $registered_count external script(s)"
    
    return 0
}

# create_script_wrapper() -> void
# Create dynamic wrapper function for each script
# Args:
#   $1 - Script name
#   $2 - Script path
#   $3 - Default parameters
create_script_wrapper() {
    local name="$1"
    local path="$2"
    local default_params="$3"
    
    # Sanitize name to create valid function
    local func_name="exec_${name//[^a-zA-Z0-9_]/_}"
    
    # Escape strings for eval
    local escaped_path=$(printf '%s\n' "$path" | sed 's/[[\.*^$()+?{|]/\\&/g')
    local escaped_name=$(printf '%s\n' "$name" | sed 's/[[\.*^$()+?{|]/\\&/g')
    local escaped_params=$(printf '%s\n' "$default_params" | sed 's/[[\.*^$()+?{|]/\\&/g')
    
    # Create dynamic function using eval
    eval "${func_name}() {
        if declare -f execute_script >/dev/null; then
            execute_script '${escaped_path}' '${escaped_name}' '${escaped_params}'
        else
            print_error 'Script executor not available'
            if declare -f log_error >/dev/null; then
                log_error 'execute_script function not found'
            fi
            echo ''
            echo -e '\${success_color}Press Enter to continue...\${NC}'
            read -s
            return 1
        fi
    }"
    
    # Export the function
    export -f "$func_name"
    
    if declare -f log_debug >/dev/null; then
        log_debug "Created wrapper function: $func_name for script: $name"
    fi
}

# =============================================================================
# Exit Function
# =============================================================================

# exit_menu() -> void
# Exit menu gracefully
exit_menu() {
    echo ""
    echo -e "${success_color}Exiting Bashmenu. Goodbye!${NC}"
    echo ""
    
    # Cleanup
    if declare -f cleanup_old_backups >/dev/null; then
        cleanup_old_backups
    fi
    
    if declare -f log_info >/dev/null; then
        log_info "Bashmenu exited"
    fi
    
    exit 0
}

# =============================================================================
# Export Functions
# =============================================================================

export -f execute_menu_item
export -f execute_auto_script
export -f register_external_scripts
export -f create_script_wrapper
export -f exit_menu
