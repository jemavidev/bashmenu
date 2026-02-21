#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Menu Display - Bashmenu
# =============================================================================
# Description: Menu display and rendering functions
# Version:     3.0
# Author:      JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Display Functions
# =============================================================================

# clear_screen() -> void
# Clear screen with anti-flickering
clear_screen() {
    if command -v tput >/dev/null 2>&1; then
        tput clear
    else
        clear
    fi
}

# display_header() -> void
# Display menu header with title and timestamp
display_header() {
    local title="${MENU_TITLE:-Bashmenu}"
    local timestamp=""

    if [[ "${SHOW_TIMESTAMP:-true}" == "true" ]]; then
        timestamp=" - $(date '+%Y-%m-%d %H:%M:%S')"
    fi

    clear_screen

    # Standard width for all headers
    local width=50
    local title_with_timestamp="$title$timestamp"
    local title_length=${#title_with_timestamp}
    local padding=$(( (width - title_length) / 2 ))
    local padding_right=$(( width - title_length - padding ))

    # Top frame
    if [[ -n "${frame_top:-}" ]]; then
        echo -e "${title_color}${frame_top}${NC}"
    fi

    # Title centered
    if [[ -n "${frame_left:-}" && -n "${frame_right:-}" ]]; then
        printf "${title_color}%s%${padding}s%s%${padding_right}s%s${NC}\n" \
            "$frame_left" "" "$title_with_timestamp" "" "$frame_right"
    else
        printf "${title_color}%${padding}s%s%${padding_right}s${NC}\n" \
            "" "$title_with_timestamp" ""
    fi

    # Bottom frame
    if [[ -n "${frame_bottom:-}" ]]; then
        echo -e "${title_color}${frame_bottom}${NC}"
    fi

    echo ""
}

# display_menu() -> void
# Display menu options with selection highlighting
# Args:
#   $1 - Selected index (default: 0)
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

        # Choose color based on selection and permissions
        local color="${option_color:-$WHITE}"
        local icon="  "

        if [[ $i -eq $selected_index ]]; then
            color="${selected_color:-$GREEN}"
            icon="▶ "
        fi

        if [[ "$can_execute" == "false" ]]; then
            color="${warning_color:-$YELLOW}"
            icon="🔒 "
        fi

        # Display option
        if [[ -n "$description" ]]; then
            printf "%s %s" "${frame_left:-}" "$icon"
            echo -e "${color}$option${NC} ${info_color:-$BLUE}($description)${NC}"
        else
            printf "%s %s" "${frame_left:-}" "$icon"
            echo -e "${color}$option${NC}"
        fi
    done
}

# display_footer() -> void
# Display menu footer with keyboard shortcuts
display_footer() {
    echo ""
    echo -e "Navigate: ${selected_color:-$GREEN}↑↓${NC} • ${success_color:-$GREEN}Enter${NC} select • ${CYAN}/${NC} search • ${CYAN}?${NC} help"
    echo -e "${BLUE}d${NC} dashboard • ${BLUE}s${NC} status • ${BLUE}r${NC} refresh • ${error_color:-$RED}q${NC} quit"
}

# refresh_menu_display() -> void
# Refresh complete menu display
# Args:
#   $1 - Menu mode (classic/hierarchical)
#   $2 - Selected index
refresh_menu_display() {
    local mode="${1:-classic}"
    local selected_index="${2:-0}"
    
    display_header
    display_menu "$selected_index"
    display_footer
}

# show_info_banner() -> void
# Show temporary information banner
# Args:
#   $1 - Message
#   $2 - Duration in seconds (default: 3)
show_info_banner() {
    local message="$1"
    local duration="${2:-3}"
    
    echo ""
    echo -e "${info_color:-$BLUE}ℹ️  $message${NC}"
    sleep "$duration"
}

# show_error_banner() -> void
# Show temporary error banner
# Args:
#   $1 - Message
#   $2 - Duration in seconds (default: 3)
show_error_banner() {
    local message="$1"
    local duration="${2:-3}"
    
    echo ""
    echo -e "${error_color:-$RED}❌ $message${NC}"
    sleep "$duration"
}

# show_success_banner() -> void
# Show temporary success banner
# Args:
#   $1 - Message
#   $2 - Duration in seconds (default: 2)
show_success_banner() {
    local message="$1"
    local duration="${2:-2}"
    
    echo ""
    echo -e "${success_color:-$GREEN}✅ $message${NC}"
    sleep "$duration"
}

# =============================================================================
# Export Functions
# =============================================================================

export -f clear_screen
export -f display_header
export -f display_menu
export -f display_footer
export -f refresh_menu_display
export -f show_info_banner
export -f show_error_banner
export -f show_success_banner
