#!/usr/bin/env bash
# Bashmenu v2.2 - Hooks System
# Event-driven hooks with priority execution

# Global hooks registry
declare -A HOOKS_REGISTRY
declare -A HOOKS_PRIORITY
declare -g HOOKS_ENABLED=true

#######################################
# Initialize hooks system
# Returns:
#   0 on success
#######################################
hooks_init() {
    HOOKS_REGISTRY=()
    HOOKS_PRIORITY=()
    HOOKS_ENABLED=true
    return 0
}

#######################################
# Register a hook
# Arguments:
#   $1 - Hook name (pre_execute, post_execute, on_error, on_load, on_exit)
#   $2 - Function name to call
#   $3 - Priority (0-100, lower = higher priority) [default: 50]
# Returns:
#   0 on success, 1 on error
#######################################
register_hook() {
    local hook_name="$1"
    local function_name="$2"
    local priority="${3:-50}"
    
    if [[ -z "$hook_name" ]] || [[ -z "$function_name" ]]; then
        echo "Error: Hook name and function required" >&2
        return 1
    fi
    
    # Validate hook name
    case "$hook_name" in
        pre_execute|post_execute|on_error|on_load|on_exit)
            ;;
        *)
            echo "Error: Invalid hook name: $hook_name" >&2
            echo "Valid hooks: pre_execute, post_execute, on_error, on_load, on_exit" >&2
            return 1
            ;;
    esac
    
    # Validate function exists
    if ! declare -f "$function_name" > /dev/null 2>&1; then
        echo "Error: Function not found: $function_name" >&2
        return 1
    fi
    
    # Validate priority
    if ! [[ "$priority" =~ ^[0-9]+$ ]] || [[ $priority -gt 100 ]]; then
        echo "Error: Priority must be 0-100" >&2
        return 1
    fi
    
    # Register hook
    local key="${hook_name}:${function_name}"
    HOOKS_REGISTRY["$key"]="$function_name"
    HOOKS_PRIORITY["$key"]="$priority"
    
    return 0
}

#######################################
# Unregister a hook
# Arguments:
#   $1 - Hook name
#   $2 - Function name
# Returns:
#   0 on success, 1 if not found
#######################################
unregister_hook() {
    local hook_name="$1"
    local function_name="$2"
    
    if [[ -z "$hook_name" ]] || [[ -z "$function_name" ]]; then
        echo "Error: Hook name and function required" >&2
        return 1
    fi
    
    local key="${hook_name}:${function_name}"
    
    if [[ -z "${HOOKS_REGISTRY[$key]}" ]]; then
        echo "Error: Hook not registered: $key" >&2
        return 1
    fi
    
    unset "HOOKS_REGISTRY[$key]"
    unset "HOOKS_PRIORITY[$key]"
    
    return 0
}

#######################################
# Execute hooks for an event
# Arguments:
#   $1 - Hook name
#   $@ - Additional arguments to pass to hook functions
# Returns:
#   0 if all hooks succeed, 1 if any hook fails or cancels
#######################################
execute_hooks() {
    local hook_name="$1"
    shift
    local hook_args=("$@")
    
    if [[ "$HOOKS_ENABLED" != "true" ]]; then
        return 0
    fi
    
    # Get all hooks for this event
    local -a hooks=()
    local -a priorities=()
    
    for key in "${!HOOKS_REGISTRY[@]}"; do
        if [[ "$key" == "${hook_name}:"* ]]; then
            hooks+=("${HOOKS_REGISTRY[$key]}")
            priorities+=("${HOOKS_PRIORITY[$key]}")
        fi
    done
    
    # Sort by priority (bubble sort for simplicity)
    local n="${#hooks[@]}"
    for ((i=0; i<n; i++)); do
        for ((j=0; j<n-i-1; j++)); do
            if [[ ${priorities[j]} -gt ${priorities[j+1]} ]]; then
                # Swap
                local temp_hook="${hooks[j]}"
                local temp_prio="${priorities[j]}"
                hooks[j]="${hooks[j+1]}"
                priorities[j]="${priorities[j+1]}"
                hooks[j+1]="$temp_hook"
                priorities[j+1]="$temp_prio"
            fi
        done
    done
    
    # Execute hooks in priority order
    for func in "${hooks[@]}"; do
        if ! "$func" "${hook_args[@]}"; then
            # Hook returned non-zero, cancel execution
            return 1
        fi
    done
    
    return 0
}

#######################################
# List registered hooks
# Arguments:
#   $1 - Hook name (optional, lists all if not specified)
# Outputs:
#   List of registered hooks
#######################################
list_hooks() {
    local filter_hook="$1"
    
    echo "Registered Hooks:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local found=false
    
    for key in "${!HOOKS_REGISTRY[@]}"; do
        local hook_name="${key%%:*}"
        local function_name="${HOOKS_REGISTRY[$key]}"
        local priority="${HOOKS_PRIORITY[$key]}"
        
        if [[ -z "$filter_hook" ]] || [[ "$hook_name" == "$filter_hook" ]]; then
            printf "  %-15s %-30s Priority: %3d\n" "$hook_name" "$function_name" "$priority"
            found=true
        fi
    done
    
    if [[ "$found" == "false" ]]; then
        echo "  No hooks registered"
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

#######################################
# Enable hooks system
#######################################
hooks_enable() {
    HOOKS_ENABLED=true
    echo "Hooks enabled"
}

#######################################
# Disable hooks system
#######################################
hooks_disable() {
    HOOKS_ENABLED=false
    echo "Hooks disabled"
}

#######################################
# Check if hooks are enabled
# Returns:
#   0 if enabled, 1 if disabled
#######################################
hooks_is_enabled() {
    [[ "$HOOKS_ENABLED" == "true" ]]
}

#######################################
# Clear all hooks
#######################################
hooks_clear() {
    HOOKS_REGISTRY=()
    HOOKS_PRIORITY=()
    echo "All hooks cleared"
}

#######################################
# Get hook count
# Arguments:
#   $1 - Hook name (optional)
# Outputs:
#   Number of registered hooks
#######################################
hooks_count() {
    local filter_hook="$1"
    local count=0
    
    for key in "${!HOOKS_REGISTRY[@]}"; do
        if [[ -z "$filter_hook" ]] || [[ "$key" == "${filter_hook}:"* ]]; then
            ((count++))
        fi
    done
    
    echo "$count"
}

# Export functions
export -f hooks_init
export -f register_hook
export -f unregister_hook
export -f execute_hooks
export -f list_hooks
export -f hooks_enable
export -f hooks_disable
export -f hooks_is_enabled
export -f hooks_clear
export -f hooks_count
