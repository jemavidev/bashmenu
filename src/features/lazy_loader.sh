#!/usr/bin/env bash
# Bashmenu v2.2 - Lazy Loading System
# Load modules on-demand for faster startup

# Global state
declare -A LOADED_MODULES
declare -A MODULE_PATHS
declare -g LAZY_LOADING_ENABLED=true

#######################################
# Initialize lazy loader
# Returns:
#   0 on success
#######################################
lazy_init() {
    LOADED_MODULES=()
    MODULE_PATHS=()
    LAZY_LOADING_ENABLED=true
    
    # Register core modules (always loaded)
    MODULE_PATHS["config"]="${SCRIPT_DIR}/src/core/config.sh"
    MODULE_PATHS["logger"]="${SCRIPT_DIR}/src/core/logger.sh"
    MODULE_PATHS["utils"]="${SCRIPT_DIR}/src/core/utils.sh"
    
    # Register optional modules (lazy loaded)
    MODULE_PATHS["search"]="${SCRIPT_DIR}/src/features/search.sh"
    MODULE_PATHS["favorites"]="${SCRIPT_DIR}/src/features/favorites.sh"
    MODULE_PATHS["hooks"]="${SCRIPT_DIR}/src/features/hooks.sh"
    MODULE_PATHS["audit"]="${SCRIPT_DIR}/src/features/audit.sh"
    MODULE_PATHS["cache"]="${SCRIPT_DIR}/src/scripts/cache.sh"
    
    return 0
}

#######################################
# Load a module
# Arguments:
#   $1 - Module name
# Returns:
#   0 on success, 1 on error
#######################################
lazy_load_module() {
    local module_name="$1"
    
    if [[ -z "$module_name" ]]; then
        echo "Error: Module name required" >&2
        return 1
    fi
    
    # Check if already loaded
    if [[ -n "${LOADED_MODULES[$module_name]}" ]]; then
        return 0
    fi
    
    # Check if lazy loading is disabled
    if [[ "$LAZY_LOADING_ENABLED" != "true" ]]; then
        return 0
    fi
    
    # Get module path
    local module_path="${MODULE_PATHS[$module_name]}"
    
    if [[ -z "$module_path" ]]; then
        echo "Error: Unknown module: $module_name" >&2
        return 1
    fi
    
    if [[ ! -f "$module_path" ]]; then
        echo "Error: Module file not found: $module_path" >&2
        return 1
    fi
    
    # Load module
    # shellcheck source=/dev/null
    if source "$module_path"; then
        LOADED_MODULES["$module_name"]=1
        return 0
    else
        echo "Error: Failed to load module: $module_name" >&2
        return 1
    fi
}

#######################################
# Preload modules
# Arguments:
#   $@ - Module names to preload
# Returns:
#   0 on success
#######################################
lazy_preload() {
    local module
    
    for module in "$@"; do
        lazy_load_module "$module" || true
    done
    
    return 0
}

#######################################
# Check if module is loaded
# Arguments:
#   $1 - Module name
# Returns:
#   0 if loaded, 1 if not
#######################################
lazy_is_loaded() {
    local module_name="$1"
    
    [[ -n "${LOADED_MODULES[$module_name]}" ]]
}

#######################################
# Get loaded modules count
# Outputs:
#   Number of loaded modules
#######################################
lazy_loaded_count() {
    echo "${#LOADED_MODULES[@]}"
}

#######################################
# List loaded modules
# Outputs:
#   List of loaded module names
#######################################
lazy_list_loaded() {
    for module in "${!LOADED_MODULES[@]}"; do
        echo "$module"
    done | sort
}

#######################################
# List available modules
# Outputs:
#   List of available module names
#######################################
lazy_list_available() {
    for module in "${!MODULE_PATHS[@]}"; do
        echo "$module"
    done | sort
}

#######################################
# Enable lazy loading
#######################################
lazy_enable() {
    LAZY_LOADING_ENABLED=true
    echo "Lazy loading enabled"
}

#######################################
# Disable lazy loading
#######################################
lazy_disable() {
    LAZY_LOADING_ENABLED=false
    echo "Lazy loading disabled"
}

#######################################
# Get lazy loading stats
# Outputs:
#   JSON with stats
#######################################
lazy_stats() {
    local total="${#MODULE_PATHS[@]}"
    local loaded="${#LOADED_MODULES[@]}"
    local percentage=0
    
    if [[ $total -gt 0 ]]; then
        percentage=$(( (loaded * 100) / total ))
    fi
    
    cat << EOF
{
  "enabled": $LAZY_LOADING_ENABLED,
  "total_modules": $total,
  "loaded_modules": $loaded,
  "load_percentage": $percentage
}
EOF
}

# Export functions
export -f lazy_init
export -f lazy_load_module
export -f lazy_preload
export -f lazy_is_loaded
export -f lazy_loaded_count
export -f lazy_list_loaded
export -f lazy_list_available
export -f lazy_enable
export -f lazy_disable
export -f lazy_stats
