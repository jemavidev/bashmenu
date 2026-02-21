#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Menu System - Bashmenu (Refactored v3.0)
# =============================================================================
# Description: Main menu system orchestrator
# Version:     3.0
# Author:      JESUS MARIA VILLALOBOS
# =============================================================================

# Get script directory
MENU_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# Load Dependencies
# =============================================================================

# Source utilities and commands
source "$MENU_SCRIPT_DIR/core/utils.sh"
source "$MENU_SCRIPT_DIR/core/commands.sh"

# =============================================================================
# Load Refactored Menu Modules
# =============================================================================

# Core modules (required)
source "$MENU_SCRIPT_DIR/menu/core.sh"
source "$MENU_SCRIPT_DIR/menu/themes.sh"
source "$MENU_SCRIPT_DIR/menu/display.sh"
source "$MENU_SCRIPT_DIR/menu/input.sh"
source "$MENU_SCRIPT_DIR/menu/navigation.sh"
source "$MENU_SCRIPT_DIR/menu/execution.sh"
source "$MENU_SCRIPT_DIR/menu/loop.sh"

# Optional modules (load if available)
if [[ -f "$MENU_SCRIPT_DIR/menu/validation.sh" ]]; then
    source "$MENU_SCRIPT_DIR/menu/validation.sh"
fi

if [[ -f "$MENU_SCRIPT_DIR/menu/help.sh" ]]; then
    source "$MENU_SCRIPT_DIR/menu/help.sh"
fi

# =============================================================================
# Module Initialization
# =============================================================================

# Initialize theme system
initialize_themes

# Log successful module loading
if declare -f log_info >/dev/null; then
    log_info "Menu system modules loaded successfully (refactored v3.0)"
fi

# =============================================================================
# Backward Compatibility Functions
# =============================================================================

# These functions maintain backward compatibility with existing code
# that may call the old menu.sh functions

# Legacy function redirects
if ! declare -f show_help_screen >/dev/null; then
    show_help_screen() {
        if declare -f display_help_screen >/dev/null; then
            display_help_screen
        else
            echo "Help system not available"
            echo "Press Enter to continue..."
            read -s
        fi
    }
fi

if ! declare -f load_script_mappings >/dev/null; then
    load_script_mappings() {
        local config_file="${CONFIG_DIR:-$PROJECT_ROOT/config}/scripts.conf"

        if [[ ! -f "$config_file" ]]; then
            return 0
        fi

        # Read the file and look for mapping lines
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Skip comments and empty lines
            [[ "$line" =~ ^# ]] && continue
            [[ -z "$line" ]] && continue

            # Look for mapping assignments
            if [[ "$line" =~ ^SCRIPT_NAME_MAPPING\[ ]]; then
                if [[ "$line" =~ SCRIPT_NAME_MAPPING\[\"([^\"]+)\"\]=\"([^\"]+)\" ]]; then
                    local key="${BASH_REMATCH[1]}"
                    local value="${BASH_REMATCH[2]}"
                    SCRIPT_NAME_MAPPING["$key"]="$value"
                    if declare -f log_debug >/dev/null; then
                        log_debug "Loaded name mapping: $key -> $value"
                    fi
                fi
            elif [[ "$line" =~ ^SCRIPT_LEVEL_MAPPING\[ ]]; then
                if [[ "$line" =~ SCRIPT_LEVEL_MAPPING\[\"([^\"]+)\"\]=\"([^\"]+)\" ]]; then
                    local key="${BASH_REMATCH[1]}"
                    local value="${BASH_REMATCH[2]}"
                    SCRIPT_LEVEL_MAPPING["$key"]="$value"
                    if declare -f log_debug >/dev/null; then
                        log_debug "Loaded level mapping: $key -> $value"
                    fi
                fi
            fi
        done < "$config_file"
    }
fi

if ! declare -f get_script_display_name >/dev/null; then
    get_script_display_name() {
        local script_name="$1"

        # Check if we have a custom mapping
        if [[ -n "${SCRIPT_NAME_MAPPING[$script_name]:-}" ]]; then
            echo "${SCRIPT_NAME_MAPPING[$script_name]}"
            return
        fi

        # Transform filename to better display name
        local display_name="$script_name"

        # Remove .sh extension if present
        display_name="${display_name%.sh}"

        # Replace underscores with spaces and capitalize words
        display_name="${display_name//_/ }"

        # Capitalize first letter of each word
        display_name="$(echo "$display_name" | sed 's/\b\w/\U&/g')"

        # Add appropriate emoji based on script name keywords
        if [[ "$display_name" =~ (Deploy|Production|Build) ]]; then
            display_name="🚀 $display_name"
        elif [[ "$display_name" =~ (Update|Pull|Download) ]]; then
            display_name="📥 $display_name"
        elif [[ "$display_name" =~ (Push|Upload|Commit) ]]; then
            display_name="⬆️ $display_name"
        elif [[ "$display_name" =~ (Rollback|Revert|Undo) ]]; then
            display_name="↩️ $display_name"
        elif [[ "$display_name" =~ (Status|Monitor|Log|Check) ]]; then
            display_name="📊 $display_name"
        elif [[ "$display_name" =~ (Restart|Service|Systemd|Nginx) ]]; then
            display_name="🔄 $display_name"
        elif [[ "$display_name" =~ (Health|Verify|Test) ]]; then
            display_name="🏥 $display_name"
        elif [[ "$display_name" =~ (Diagnostic|Debug|Analyze) ]]; then
            display_name="🔍 $display_name"
        else
            display_name="🚀 $display_name"
        fi

        echo "$display_name"
    }
fi

# =============================================================================
# Module Status Report
# =============================================================================

if declare -f log_info >/dev/null; then
    log_info "=== Menu System v3.0 Loaded ==="
    log_info "Core modules: ✓"
    log_info "Theme system: ✓"
    log_info "Display system: ✓"
    log_info "Input system: ✓"
    log_info "Navigation system: ✓"
    log_info "Execution system: ✓"
    log_info "Loop system: ✓"
    log_info "================================"
fi

# =============================================================================
# Export All Functions
# =============================================================================

# Export backward compatibility functions
export -f load_script_mappings
export -f get_script_display_name
export -f show_help_screen
