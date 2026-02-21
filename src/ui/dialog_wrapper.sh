#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Dialog/Whiptail Wrapper for Bashmenu
# =============================================================================
# Descripción: Wrapper para integración de dialog/whiptail con fallback
# Versión:     2.1
# Autor:       JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Global Variables
# =============================================================================

DIALOG_TOOL=""
DIALOG_AVAILABLE=false
DIALOG_HEIGHT="${DIALOG_HEIGHT:-20}"
DIALOG_WIDTH="${DIALOG_WIDTH:-70}"
DIALOG_MENU_HEIGHT="${DIALOG_MENU_HEIGHT:-15}"

# =============================================================================
# Detection Functions
# =============================================================================

# detect_dialog_tool() - Detect available dialog tool
# Returns: 0 if found, 1 if not found
detect_dialog_tool() {
    if command -v dialog &>/dev/null; then
        DIALOG_TOOL="dialog"
        DIALOG_AVAILABLE=true
        if declare -f log_info &>/dev/null; then
            log_info "Dialog tool detected: dialog"
        fi
        return 0
    elif command -v whiptail &>/dev/null; then
        DIALOG_TOOL="whiptail"
        DIALOG_AVAILABLE=true
        if declare -f log_info &>/dev/null; then
            log_info "Dialog tool detected: whiptail"
        fi
        return 0
    else
        DIALOG_AVAILABLE=false
        if declare -f log_debug &>/dev/null; then
            log_debug "No dialog tool found, using classic UI"
        fi
        return 1
    fi
}

# is_dialog_available() - Check if dialog is available
# Returns: 0 if available, 1 if not
is_dialog_available() {
    [[ "$DIALOG_AVAILABLE" == "true" ]]
}

# =============================================================================
# Menu Functions
# =============================================================================

# show_dialog_menu() - Display menu using dialog/whiptail
# Usage: show_dialog_menu <title> <text> <items...>
# Items format: "tag" "description"
# Returns: Selected tag in stdout
show_dialog_menu() {
    local title="$1"
    local text="$2"
    shift 2
    
    if ! is_dialog_available; then
        echo "ERROR: Dialog not available" >&2
        return 1
    fi
    
    local temp_file=$(mktemp)
    
    case "$DIALOG_TOOL" in
        dialog)
            dialog --clear \
                   --title "$title" \
                   --menu "$text" \
                   "$DIALOG_HEIGHT" "$DIALOG_WIDTH" "$DIALOG_MENU_HEIGHT" \
                   "$@" \
                   2>"$temp_file"
            ;;
        whiptail)
            whiptail --clear \
                     --title "$title" \
                     --menu "$text" \
                     "$DIALOG_HEIGHT" "$DIALOG_WIDTH" "$DIALOG_MENU_HEIGHT" \
                     "$@" \
                     2>"$temp_file"
            ;;
    esac
    
    local exit_code=$?
    local result=$(cat "$temp_file")
    rm -f "$temp_file"
    
    if [[ $exit_code -eq 0 ]]; then
        echo "$result"
        return 0
    else
        return 1
    fi
}

# show_dialog_checklist() - Display checklist using dialog/whiptail
# Usage: show_dialog_checklist <title> <text> <items...>
# Items format: "tag" "description" "status" (on/off)
# Returns: Selected tags in stdout (space-separated)
show_dialog_checklist() {
    local title="$1"
    local text="$2"
    shift 2
    
    if ! is_dialog_available; then
        echo "ERROR: Dialog not available" >&2
        return 1
    fi
    
    local temp_file=$(mktemp)
    
    case "$DIALOG_TOOL" in
        dialog)
            dialog --clear \
                   --title "$title" \
                   --checklist "$text" \
                   "$DIALOG_HEIGHT" "$DIALOG_WIDTH" "$DIALOG_MENU_HEIGHT" \
                   "$@" \
                   2>"$temp_file"
            ;;
        whiptail)
            whiptail --clear \
                     --title "$title" \
                     --checklist "$text" \
                     "$DIALOG_HEIGHT" "$DIALOG_WIDTH" "$DIALOG_MENU_HEIGHT" \
                     "$@" \
                     2>"$temp_file"
            ;;
    esac
    
    local exit_code=$?
    local result=$(cat "$temp_file")
    rm -f "$temp_file"
    
    if [[ $exit_code -eq 0 ]]; then
        echo "$result"
        return 0
    else
        return 1
    fi
}

# show_dialog_radiolist() - Display radiolist using dialog/whiptail
# Usage: show_dialog_radiolist <title> <text> <items...>
# Items format: "tag" "description" "status" (on/off)
# Returns: Selected tag in stdout
show_dialog_radiolist() {
    local title="$1"
    local text="$2"
    shift 2
    
    if ! is_dialog_available; then
        echo "ERROR: Dialog not available" >&2
        return 1
    fi
    
    local temp_file=$(mktemp)
    
    case "$DIALOG_TOOL" in
        dialog)
            dialog --clear \
                   --title "$title" \
                   --radiolist "$text" \
                   "$DIALOG_HEIGHT" "$DIALOG_WIDTH" "$DIALOG_MENU_HEIGHT" \
                   "$@" \
                   2>"$temp_file"
            ;;
        whiptail)
            whiptail --clear \
                     --title "$title" \
                     --radiolist "$text" \
                     "$DIALOG_HEIGHT" "$DIALOG_WIDTH" "$DIALOG_MENU_HEIGHT" \
                     "$@" \
                     2>"$temp_file"
            ;;
    esac
    
    local exit_code=$?
    local result=$(cat "$temp_file")
    rm -f "$temp_file"
    
    if [[ $exit_code -eq 0 ]]; then
        echo "$result"
        return 0
    else
        return 1
    fi
}

# =============================================================================
# Input Functions
# =============================================================================

# show_dialog_input() - Display input box
# Usage: show_dialog_input <title> <text> [default_value]
# Returns: User input in stdout
show_dialog_input() {
    local title="$1"
    local text="$2"
    local default="${3:-}"
    
    if ! is_dialog_available; then
        echo "ERROR: Dialog not available" >&2
        return 1
    fi
    
    local temp_file=$(mktemp)
    
    case "$DIALOG_TOOL" in
        dialog)
            dialog --clear \
                   --title "$title" \
                   --inputbox "$text" \
                   10 "$DIALOG_WIDTH" \
                   "$default" \
                   2>"$temp_file"
            ;;
        whiptail)
            whiptail --clear \
                     --title "$title" \
                     --inputbox "$text" \
                     10 "$DIALOG_WIDTH" \
                     "$default" \
                     2>"$temp_file"
            ;;
    esac
    
    local exit_code=$?
    local result=$(cat "$temp_file")
    rm -f "$temp_file"
    
    if [[ $exit_code -eq 0 ]]; then
        echo "$result"
        return 0
    else
        return 1
    fi
}

# show_dialog_password() - Display password input box
# Usage: show_dialog_password <title> <text>
# Returns: Password in stdout
show_dialog_password() {
    local title="$1"
    local text="$2"
    
    if ! is_dialog_available; then
        echo "ERROR: Dialog not available" >&2
        return 1
    fi
    
    local temp_file=$(mktemp)
    
    case "$DIALOG_TOOL" in
        dialog)
            dialog --clear \
                   --title "$title" \
                   --insecure \
                   --passwordbox "$text" \
                   10 "$DIALOG_WIDTH" \
                   2>"$temp_file"
            ;;
        whiptail)
            whiptail --clear \
                     --title "$title" \
                     --passwordbox "$text" \
                     10 "$DIALOG_WIDTH" \
                     2>"$temp_file"
            ;;
    esac
    
    local exit_code=$?
    local result=$(cat "$temp_file")
    rm -f "$temp_file"
    
    if [[ $exit_code -eq 0 ]]; then
        echo "$result"
        return 0
    else
        return 1
    fi
}

# =============================================================================
# Message Functions
# =============================================================================

# show_dialog_msgbox() - Display message box
# Usage: show_dialog_msgbox <title> <text> [height] [width]
show_dialog_msgbox() {
    local title="$1"
    local text="$2"
    local height="${3:-10}"
    local width="${4:-$DIALOG_WIDTH}"
    
    if ! is_dialog_available; then
        echo "ERROR: Dialog not available" >&2
        return 1
    fi
    
    case "$DIALOG_TOOL" in
        dialog)
            dialog --clear \
                   --title "$title" \
                   --msgbox "$text" \
                   "$height" "$width"
            ;;
        whiptail)
            whiptail --clear \
                     --title "$title" \
                     --msgbox "$text" \
                     "$height" "$width"
            ;;
    esac
}

# show_dialog_infobox() - Display info box (auto-dismiss)
# Usage: show_dialog_infobox <title> <text> [height] [width]
show_dialog_infobox() {
    local title="$1"
    local text="$2"
    local height="${3:-5}"
    local width="${4:-50}"
    
    if ! is_dialog_available; then
        return 1
    fi
    
    case "$DIALOG_TOOL" in
        dialog)
            dialog --clear \
                   --title "$title" \
                   --infobox "$text" \
                   "$height" "$width"
            ;;
        whiptail)
            whiptail --clear \
                     --title "$title" \
                     --infobox "$text" \
                     "$height" "$width"
            ;;
    esac
}

# show_dialog_yesno() - Display yes/no dialog
# Usage: show_dialog_yesno <title> <text>
# Returns: 0 for yes, 1 for no
show_dialog_yesno() {
    local title="$1"
    local text="$2"
    
    if ! is_dialog_available; then
        echo "ERROR: Dialog not available" >&2
        return 1
    fi
    
    case "$DIALOG_TOOL" in
        dialog)
            dialog --clear \
                   --title "$title" \
                   --yesno "$text" \
                   10 "$DIALOG_WIDTH"
            ;;
        whiptail)
            whiptail --clear \
                     --title "$title" \
                     --yesno "$text" \
                     10 "$DIALOG_WIDTH"
            ;;
    esac
    
    return $?
}

# =============================================================================
# Progress Functions
# =============================================================================

# show_dialog_gauge() - Display progress gauge
# Usage: echo "percentage" | show_dialog_gauge <title> <text> [height] [width]
show_dialog_gauge() {
    local title="$1"
    local text="$2"
    local height="${3:-8}"
    local width="${4:-$DIALOG_WIDTH}"
    
    if ! is_dialog_available; then
        return 1
    fi
    
    case "$DIALOG_TOOL" in
        dialog)
            dialog --clear \
                   --title "$title" \
                   --gauge "$text" \
                   "$height" "$width" 0
            ;;
        whiptail)
            whiptail --clear \
                     --title "$title" \
                     --gauge "$text" \
                     "$height" "$width" 0
            ;;
    esac
}

# =============================================================================
# File Selection Functions
# =============================================================================

# show_dialog_fselect() - Display file selection dialog
# Usage: show_dialog_fselect <title> <path> [height] [width]
# Returns: Selected file path in stdout
show_dialog_fselect() {
    local title="$1"
    local path="${2:-.}"
    local height="${3:-15}"
    local width="${4:-$DIALOG_WIDTH}"
    
    if ! is_dialog_available; then
        echo "ERROR: Dialog not available" >&2
        return 1
    fi
    
    # Only dialog supports fselect, not whiptail
    if [[ "$DIALOG_TOOL" != "dialog" ]]; then
        echo "ERROR: File selection requires dialog (not whiptail)" >&2
        return 1
    fi
    
    local temp_file=$(mktemp)
    
    dialog --clear \
           --title "$title" \
           --fselect "$path" \
           "$height" "$width" \
           2>"$temp_file"
    
    local exit_code=$?
    local result=$(cat "$temp_file")
    rm -f "$temp_file"
    
    if [[ $exit_code -eq 0 ]]; then
        echo "$result"
        return 0
    else
        return 1
    fi
}

# show_dialog_dselect() - Display directory selection dialog
# Usage: show_dialog_dselect <title> <path> [height] [width]
# Returns: Selected directory path in stdout
show_dialog_dselect() {
    local title="$1"
    local path="${2:-.}"
    local height="${3:-15}"
    local width="${4:-$DIALOG_WIDTH}"
    
    if ! is_dialog_available; then
        echo "ERROR: Dialog not available" >&2
        return 1
    fi
    
    # Only dialog supports dselect, not whiptail
    if [[ "$DIALOG_TOOL" != "dialog" ]]; then
        echo "ERROR: Directory selection requires dialog (not whiptail)" >&2
        return 1
    fi
    
    local temp_file=$(mktemp)
    
    dialog --clear \
           --title "$title" \
           --dselect "$path" \
           "$height" "$width" \
           2>"$temp_file"
    
    local exit_code=$?
    local result=$(cat "$temp_file")
    rm -f "$temp_file"
    
    if [[ $exit_code -eq 0 ]]; then
        echo "$result"
        return 0
    else
        return 1
    fi
}

# =============================================================================
# Bashmenu Integration Functions
# =============================================================================

# convert_menu_to_dialog() - Convert Bashmenu arrays to dialog format
# Usage: convert_menu_to_dialog
# Uses global arrays: menu_options, menu_descriptions
# Returns: Dialog-formatted items
convert_menu_to_dialog() {
    local items=()
    
    for i in "${!menu_options[@]}"; do
        local tag="$((i+1))"
        local option="${menu_options[$i]}"
        local description="${menu_descriptions[$i]:-}"
        
        # Truncate long descriptions
        if [[ ${#description} -gt 50 ]]; then
            description="${description:0:47}..."
        fi
        
        items+=("$tag" "$option - $description")
    done
    
    echo "${items[@]}"
}

# show_bashmenu_dialog() - Show Bashmenu using dialog
# Usage: show_bashmenu_dialog <title>
# Uses global arrays: menu_options, menu_descriptions
# Returns: Selected index (0-based) in stdout
show_bashmenu_dialog() {
    local title="${1:-Bashmenu}"
    
    if ! is_dialog_available; then
        return 1
    fi
    
    # Convert menu arrays to dialog format
    local -a items=()
    for i in "${!menu_options[@]}"; do
        local tag="$i"
        local option="${menu_options[$i]}"
        local description="${menu_descriptions[$i]:-}"
        
        # Combine option and description
        local display="$option"
        if [[ -n "$description" ]]; then
            display="$option"
        fi
        
        items+=("$tag" "$display")
    done
    
    # Show dialog menu
    local selection
    selection=$(show_dialog_menu "$title" "Select an option:" "${items[@]}")
    
    if [[ $? -eq 0 ]] && [[ -n "$selection" ]]; then
        echo "$selection"
        return 0
    else
        return 1
    fi
}

# =============================================================================
# Utility Functions
# =============================================================================

# clear_dialog() - Clear dialog screen
clear_dialog() {
    if is_dialog_available; then
        case "$DIALOG_TOOL" in
            dialog)
                dialog --clear
                ;;
            whiptail)
                clear
                ;;
        esac
    fi
}

# =============================================================================
# Initialization
# =============================================================================

# Auto-detect dialog tool on module load
detect_dialog_tool

# =============================================================================
# Export Functions
# =============================================================================

export -f detect_dialog_tool
export -f is_dialog_available
export -f show_dialog_menu
export -f show_dialog_checklist
export -f show_dialog_radiolist
export -f show_dialog_input
export -f show_dialog_password
export -f show_dialog_msgbox
export -f show_dialog_infobox
export -f show_dialog_yesno
export -f show_dialog_gauge
export -f show_dialog_fselect
export -f show_dialog_dselect
export -f convert_menu_to_dialog
export -f show_bashmenu_dialog
export -f clear_dialog
