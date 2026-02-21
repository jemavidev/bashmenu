#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Menu Input - Bashmenu
# =============================================================================
# Description: Input handling and keyboard navigation
# Version:     3.0
# Author:      JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Input Reading Functions
# =============================================================================

# read_input() -> string
# Read user input with timeout - navigation only (no number input)
# Returns: Key pressed or "timeout"
read_input() {
    local timeout="${INPUT_TIMEOUT:-300}"

    # Check if timeout is disabled
    if [[ "${SESSION_TIMEOUT_ENABLED:-true}" != "true" ]]; then
        timeout=0  # No timeout
    fi

    # Read single character to handle navigation keys and Enter
    while true; do
        local char=""
        local read_success=false

        # Read single character with timeout
        if [[ $timeout -eq 0 ]]; then
            # No timeout - wait indefinitely
            if read -n1 -s -t 0.05 char; then
                read_success=true
            fi
        elif read -t "$timeout" -n1 -s char; then
            read_success=true
        else
            # Timeout occurred
            echo "timeout"
            return
        fi

        if [[ "$read_success" == "true" ]]; then
            case "$char" in
                $'\e')  # Escape sequence start
                    read -t 0.05 -n2 -s rest
                    case "$rest" in
                        "[A") echo "UP" ; return ;;
                        "[B") echo "DOWN" ; return ;;
                        "[C") echo "RIGHT" ; return ;;
                        "[D") echo "LEFT" ; return ;;
                        "[H") echo "HOME" ; return ;;
                        "[F") echo "END" ; return ;;
                        "") echo "ESC" ; return ;;
                        *) echo "$char$rest" ; return ;;
                    esac
                    ;;
                "")  # Enter key
                    echo "ENTER"
                    return
                    ;;
                d|D|s|S|r|R|q|Q)  # Footer command keys
                    echo "$char"
                    return
                    ;;
                /|?)  # Search and help keys
                    echo "$char"
                    return
                    ;;
                *)  # Other character - ignore
                    continue
                    ;;
            esac
        fi
    done
}

# =============================================================================
# Keyboard Navigation Functions
# =============================================================================

# handle_keyboard_input() -> int
# Handle keyboard input for navigation
# Args:
#   $1 - Key pressed
#   $2 - Current selection index
#   $3 - Maximum selection index
# Returns: New selection index
handle_keyboard_input() {
    local key="$1"
    local current_selection="$2"
    local max_selection="$3"
    
    case $key in
        "UP"|"k")
            if [[ $current_selection -gt 0 ]]; then
                echo $((current_selection - 1))
            else
                echo $((max_selection - 1))
            fi
            ;;
        "DOWN"|"j")
            if [[ $current_selection -lt $((max_selection - 1)) ]]; then
                echo $((current_selection + 1))
            else
                echo 0
            fi
            ;;
        "HOME"|"g")
            echo 0
            ;;
        "END"|"G")
            echo $((max_selection - 1))
            ;;
        *)
            echo "$current_selection"
            ;;
    esac
}

# =============================================================================
# Input Validation Functions
# =============================================================================

# validate_numeric_input() -> int
# Validate numeric input
# Args:
#   $1 - Input string
#   $2 - Maximum value
# Returns: 0 if valid, 1 if invalid
validate_numeric_input() {
    local input="$1"
    local max_value="$2"
    
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        if [[ $input -ge 1 && $input -le $max_value ]]; then
            return 0
        fi
    fi
    return 1
}

# =============================================================================
# Export Functions
# =============================================================================

export -f read_input
export -f handle_keyboard_input
export -f validate_numeric_input
