#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Menu Core - Bashmenu
# =============================================================================
# Description: Core menu system functionality
# Version:     3.0
# Author:      JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Menu Data Structures
# =============================================================================

# Default menu options
declare -ga menu_options=()
declare -ga menu_commands=()
declare -ga menu_descriptions=()
declare -ga menu_levels=()

# Script entries from configuration
declare -gA SCRIPT_ENTRIES=()

# Script name mapping for better display names
declare -gA SCRIPT_NAME_MAPPING=()

# Script level mapping for permissions
declare -gA SCRIPT_LEVEL_MAPPING=()

# Auto-detected scripts array (from script_loader.sh)
declare -gA AUTO_SCRIPTS=()

# =============================================================================
# Menu Initialization
# =============================================================================

# initialize_menu() -> void
# Initializes the menu system and loads scripts
initialize_menu() {
    # Clear arrays
    menu_options=()
    menu_commands=()
    menu_descriptions=()
    menu_levels=()

    # Initialize arrays to prevent unbound variable errors
    AUTO_SCRIPTS=()
    SCRIPT_ENTRIES=()

    if declare -f log_info >/dev/null; then
        log_info "Initializing menu system"
    fi

    # Load manual scripts from scripts.conf if enabled
    if [[ "${ENABLE_MANUAL_SCRIPTS:-true}" == "true" ]]; then
        load_manual_scripts
    fi

    # Load custom mappings from scripts.conf
    load_script_mappings

    # Register scripts as menu items
    if declare -f register_external_scripts >/dev/null; then
        register_external_scripts
    fi

    # Auto-scan plugin directories if enabled
    if [[ "${ENABLE_AUTO_SCAN:-true}" == "true" ]]; then
        auto_scan_plugins
    else
        # Add Exit option for classic mode
        add_menu_item "Exit" "exit_menu" "Exit the menu" 1
    fi

    log_menu_initialization_complete
}

# =============================================================================
# Menu Item Management
# =============================================================================

# add_menu_item() -> int
# Add menu item with duplicate prevention
# Args:
#   $1 - Display name
#   $2 - Command
#   $3 - Description
#   $4 - Permission level (default: 1)
# Returns: 0 on success, 1 if duplicate
add_menu_item() {
    local display_name="$1"
    local command="$2"
    local description="$3"
    local level="${4:-1}"
    
    # Check for duplicate commands
    for i in "${!menu_commands[@]}"; do
        if [[ "${menu_commands[$i]}" == "$command" ]]; then
            if declare -f log_debug >/dev/null; then
                log_debug "Menu item already exists, skipping: $display_name ($command)"
            fi
            return 1
        fi
    done
    
    # Check for duplicate display names
    for i in "${!menu_options[@]}"; do
        if [[ "${menu_options[$i]}" == "$display_name" ]]; then
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
# Helper Functions
# =============================================================================

load_manual_scripts() {
    local scripts_config="${CONFIG_DIR:-$PROJECT_ROOT/config}/scripts.conf"

    if [[ -f "$scripts_config" ]]; then
        if declare -f log_info >/dev/null; then
            log_info "Loading manual scripts from: $scripts_config"
        fi

        if declare -f load_script_config >/dev/null; then
            load_script_config "$scripts_config"
            if declare -f log_info >/dev/null; then
                log_info "Manual scripts loaded: ${#SCRIPT_ENTRIES[@]}"
            fi
        fi
    else
        if declare -f log_debug >/dev/null; then
            log_debug "No scripts.conf found at: $scripts_config"
        fi
    fi
}

auto_scan_plugins() {
    if declare -f scan_plugin_directories >/dev/null; then
        scan_plugin_directories

        # Build hierarchical menu structure
        if declare -f build_hierarchical_menu >/dev/null; then
            build_hierarchical_menu
        fi
    else
        if declare -f log_warn >/dev/null; then
            log_warn "Auto-scan functions not available"
        fi
    fi
}

log_menu_initialization_complete() {
    if declare -f log_info >/dev/null; then
        local auto_count=0
        if [[ "${ENABLE_AUTO_SCAN:-true}" == "true" ]]; then
            auto_count=$(count_auto_scripts 2>/dev/null || echo 0)
        fi
        local total_items=$(( ${#menu_options[@]} + auto_count ))
        log_info "Menu initialized with $total_items items (manual: ${#menu_options[@]}, auto: $auto_count)"
    fi
}

# =============================================================================
# Export Functions
# =============================================================================

export -f initialize_menu
export -f add_menu_item
