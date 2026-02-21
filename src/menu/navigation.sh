#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Menu Navigation - Bashmenu
# =============================================================================
# Description: Menu navigation and hierarchical directory handling
# Version:     3.0
# Author:      JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Hierarchical Menu System
# =============================================================================

# Array for hierarchical directory/script structure
declare -gA menu_hierarchy=()

# Array for breadcrumb navigation (current path)
declare -ga current_path=()

# =============================================================================
# Hierarchical Menu Functions
# =============================================================================

# build_hierarchical_menu() -> void
# Build hierarchical menu structure from auto-detected scripts
build_hierarchical_menu() {
    if declare -f log_info >/dev/null; then
        log_info "Building hierarchical menu structure"
    fi

    # Process auto-detected scripts to extract unique directories
    local directories_found=()
    for key in "${!AUTO_SCRIPTS[@]}"; do
        if [[ $key =~ _directory$ ]]; then
            local dir_name="${AUTO_SCRIPTS[$key]}"
            # Avoid duplicates
            local already_added=false
            for existing in "${directories_found[@]}"; do
                if [[ "$existing" == "$dir_name" ]]; then
                    already_added=true
                    break
                fi
            done
            if [[ "$already_added" == "false" ]]; then
                directories_found+=("$dir_name")
            fi
        fi
    done

    # Create directory hierarchy
    for dir_name in "${directories_found[@]}"; do
        add_directory_to_hierarchy "$dir_name"
    done

    if declare -f log_info >/dev/null; then
        log_info "Built hierarchical menu with ${#directories_found[@]} directories"
    fi
}

# add_directory_to_hierarchy() -> void
# Add directory to hierarchy (creates parent structure)
# Args:
#   $1 - Directory path
add_directory_to_hierarchy() {
    local dir_path="$1"

    if [[ "$dir_path" == "." ]]; then
        return  # Root directory doesn't need entry
    fi

    local current_path=""
    IFS='/' read -ra DIR_PARTS <<< "$dir_path"

    for part in "${DIR_PARTS[@]}"; do
        if [[ -n "$part" ]]; then
            current_path="${current_path:+$current_path/}$part"

            # Only add if doesn't exist
            if [[ -z "${menu_hierarchy[$current_path:type]:-}" ]]; then
                menu_hierarchy["$current_path:type"]="directory"
                menu_hierarchy["$current_path:name"]="$part"
                menu_hierarchy["$current_path:description"]="Directory: $part"
            fi
        fi
    done
}

# generate_directory_menu() -> void
# Generate menu for a specific directory
# Args:
#   $1 - Current directory path (empty for root)
generate_directory_menu() {
    local current_dir="${1:-}"

    # Clear current menu
    menu_options=()
    menu_commands=()
    menu_descriptions=()
    menu_levels=()

    # Add ".." option to go up (if not at root)
    if [[ -n "$current_dir" ]]; then
        add_menu_item "⬆️ .. (Subir)" "navigate_up" "Ir al directorio superior" 1
    fi

    # Find items in current directory
    local found_items=false

    # Use separate arrays for directories and scripts
    local dirs_to_sort=()
    local scripts_to_sort=()

    if [[ -z "$current_dir" ]]; then
        # Root directory: dynamically scan all available directories
        scan_root_directories
        found_items=true
    else
        # Subdirectory: show subdirectories and scripts belonging to this directory
        scan_subdirectory "$current_dir"
        found_items=true
    fi

    # Sort directories and scripts alphabetically
    IFS=$'\n' sorted_dirs=($(sort <<<"${dirs_to_sort[*]}"))
    IFS=$'\n' sorted_scripts=($(sort <<<"${scripts_to_sort[*]}"))
    unset IFS

    # Add sorted directories to menu first
    add_sorted_directories_to_menu "$current_dir" "${sorted_dirs[@]}"

    # Add sorted scripts to menu
    add_sorted_scripts_to_menu "${sorted_scripts[@]}"

    # If no items and at root, show alternative message
    if [[ "$found_items" == "false" && -z "$current_dir" ]]; then
        add_menu_item "No scripts found in plugin directories" "no_scripts" \
            "To add scripts:\n1. Place executable scripts in: ${PLUGIN_DIR:-./plugins}/\n2. Or configure manually in: ${CONFIG_DIR:-./config}/scripts.conf" 1
    fi
}

# =============================================================================
# Navigation Handlers
# =============================================================================

# handle_navigation() -> void
# Handle navigation commands
# Args:
#   $1 - Navigation command
handle_navigation() {
    local command="$1"

    case "$command" in
        navigate_up)
            # Go to parent directory
            if [[ ${#current_path[@]} -gt 0 ]]; then
                unset current_path[${#current_path[@]}-1]
            fi
            ;;
        navigate:*)
            # Go to subdirectory
            local target_dir="${command#navigate:}"
            current_path+=("$target_dir")
            ;;
        execute_auto:*)
            # Execute auto-detected script
            local script_key="${command#execute_auto:}"
            execute_auto_script "$script_key"
            ;;
        no_scripts)
            # No scripts, show message
            show_no_scripts_message
            ;;
        *)
            # Unknown command
            if declare -f log_warn >/dev/null; then
                log_warn "Unknown navigation command: $command"
            fi
            ;;
    esac
}

# =============================================================================
# Path Management Functions
# =============================================================================

# get_current_path_string() -> string
# Get current path as string
# Returns: Current path string
get_current_path_string() {
    if [[ ${#current_path[@]} -eq 0 ]]; then
        echo ""
    else
        local path_str="${current_path[*]}"
        echo "${path_str// /\/}"
    fi
}

# get_breadcrumb() -> string
# Get breadcrumb for display in header
# Returns: Breadcrumb string
get_breadcrumb() {
    if [[ ${#current_path[@]} -eq 0 ]]; then
        echo "Root"
    else
        echo "Root/${current_path[*]}"
    fi
}

# =============================================================================
# Helper Functions (to be implemented in separate modules)
# =============================================================================

scan_root_directories() {
    # Implementation moved to menu_scanner.sh
    if declare -f _scan_root_directories >/dev/null; then
        _scan_root_directories
    fi
}

scan_subdirectory() {
    # Implementation moved to menu_scanner.sh
    if declare -f _scan_subdirectory >/dev/null; then
        _scan_subdirectory "$@"
    fi
}

add_sorted_directories_to_menu() {
    # Implementation moved to menu_builder.sh
    if declare -f _add_sorted_directories_to_menu >/dev/null; then
        _add_sorted_directories_to_menu "$@"
    fi
}

add_sorted_scripts_to_menu() {
    # Implementation moved to menu_builder.sh
    if declare -f _add_sorted_scripts_to_menu >/dev/null; then
        _add_sorted_scripts_to_menu "$@"
    fi
}

# =============================================================================
# Export Functions
# =============================================================================

export -f build_hierarchical_menu
export -f add_directory_to_hierarchy
export -f generate_directory_menu
export -f handle_navigation
export -f get_current_path_string
export -f get_breadcrumb
