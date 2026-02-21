#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Menu Themes - Bashmenu
# =============================================================================
# Description: Theme system for menu display
# Version:     3.0
# Author:      JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Theme Variables
# =============================================================================

# Declare theme variables as global
declare -g default_frame_top default_frame_bottom default_frame_left default_frame_right
declare -g default_title_color default_option_color default_selected_color
declare -g default_error_color default_success_color default_warning_color default_info_color

declare -g dark_frame_top dark_frame_bottom dark_frame_left dark_frame_right
declare -g dark_title_color dark_option_color dark_selected_color
declare -g dark_error_color dark_success_color dark_warning_color dark_info_color

declare -g colorful_frame_top colorful_frame_bottom colorful_frame_left colorful_frame_right
declare -g colorful_title_color colorful_option_color colorful_selected_color
declare -g colorful_error_color colorful_success_color colorful_warning_color colorful_info_color

declare -g minimal_frame_top minimal_frame_bottom minimal_frame_left minimal_frame_right
declare -g minimal_title_color minimal_option_color minimal_selected_color
declare -g minimal_error_color minimal_success_color minimal_warning_color minimal_info_color

declare -g modern_frame_top modern_frame_bottom modern_frame_left modern_frame_right
declare -g modern_title_color modern_option_color modern_selected_color
declare -g modern_error_color modern_success_color modern_warning_color modern_info_color

# =============================================================================
# Theme Initialization
# =============================================================================

# initialize_themes() -> void
# Initialize all available themes
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

# =============================================================================
# Theme Loading
# =============================================================================

# load_theme() -> int
# Load specified theme
# Args:
#   $1 - Theme name (default, dark, colorful, minimal, modern)
#   $2 - Fallback attempted flag (internal use)
# Returns: 0 on success, 1 on failure
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
    info_color="${theme_name}_info_color"
    
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
    info_color="${!info_color}"

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
# Theme Utilities
# =============================================================================

# list_available_themes() -> void
# List all available themes
list_available_themes() {
    echo "Available themes:"
    echo "  - default   : Classic interface with cyan accents"
    echo "  - dark      : Dark mode with purple accents"
    echo "  - colorful  : Bright colors with indicators"
    echo "  - minimal   : Clean, minimal interface"
    echo "  - modern    : Modern look with 256-color support"
}

# get_current_theme() -> string
# Get currently loaded theme name
# Returns: Theme name or "unknown"
get_current_theme() {
    echo "${DEFAULT_THEME:-default}"
}

# =============================================================================
# Export Functions
# =============================================================================

export -f initialize_themes
export -f load_theme
export -f list_available_themes
export -f get_current_theme
