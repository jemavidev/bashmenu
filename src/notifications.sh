#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Notification System for Bashmenu
# =============================================================================
# Descripción: Sistema de notificaciones desktop e in-terminal
# Versión:     2.1
# Autor:       JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Global Variables
# =============================================================================

NOTIFY_SEND_AVAILABLE=false
NOTIFICATION_TIMEOUT="${NOTIFICATION_TIMEOUT:-5000}"
NOTIFICATION_URGENCY="${NOTIFICATION_URGENCY:-normal}"
ENABLE_DESKTOP_NOTIFICATIONS="${ENABLE_DESKTOP_NOTIFICATIONS:-true}"
ENABLE_SOUND_NOTIFICATIONS="${ENABLE_SOUND_NOTIFICATIONS:-false}"

# Notification history
declare -a NOTIFICATION_HISTORY=()
MAX_NOTIFICATION_HISTORY=100

# =============================================================================
# Detection Functions
# =============================================================================

# detect_notify_send() - Detect if notify-send is available
# Returns: 0 if found, 1 if not found
detect_notify_send() {
    if command -v notify-send &>/dev/null; then
        NOTIFY_SEND_AVAILABLE=true
        if declare -f log_debug &>/dev/null; then
            log_debug "notify-send detected and available"
        fi
        return 0
    else
        NOTIFY_SEND_AVAILABLE=false
        if declare -f log_debug &>/dev/null; then
            log_debug "notify-send not found, desktop notifications disabled"
        fi
        return 1
    fi
}

# is_notify_send_available() - Check if notify-send is available
# Returns: 0 if available, 1 if not
is_notify_send_available() {
    [[ "$NOTIFY_SEND_AVAILABLE" == "true" ]]
}

# =============================================================================
# Desktop Notification Functions
# =============================================================================

# send_notification() - Send desktop notification
# Usage: send_notification <title> <message> [urgency] [icon]
# Urgency: low, normal, critical
# Icon: dialog-information, dialog-warning, dialog-error, etc.
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-$NOTIFICATION_URGENCY}"
    local icon="${4:-dialog-information}"
    
    # Check if desktop notifications are enabled
    if [[ "$ENABLE_DESKTOP_NOTIFICATIONS" != "true" ]]; then
        return 0
    fi
    
    # Check if notify-send is available
    if ! is_notify_send_available; then
        return 1
    fi
    
    # Send notification
    notify-send \
        --urgency="$urgency" \
        --icon="$icon" \
        --expire-time="$NOTIFICATION_TIMEOUT" \
        "$title" \
        "$message" \
        2>/dev/null
    
    # Add to history
    add_to_notification_history "$title" "$message" "desktop" "$urgency"
    
    # Play sound if enabled
    if [[ "$ENABLE_SOUND_NOTIFICATIONS" == "true" ]]; then
        play_notification_sound "$urgency"
    fi
    
    return 0
}

# send_success_notification() - Send success notification
# Usage: send_success_notification <title> <message>
send_success_notification() {
    local title="$1"
    local message="$2"
    
    send_notification "$title" "$message" "normal" "dialog-information"
}

# send_warning_notification() - Send warning notification
# Usage: send_warning_notification <title> <message>
send_warning_notification() {
    local title="$1"
    local message="$2"
    
    send_notification "$title" "$message" "normal" "dialog-warning"
}

# send_error_notification() - Send error notification
# Usage: send_error_notification <title> <message>
send_error_notification() {
    local title="$1"
    local message="$2"
    
    send_notification "$title" "$message" "critical" "dialog-error"
}

# =============================================================================
# In-Terminal Notification Functions
# =============================================================================

# show_terminal_notification() - Show in-terminal notification banner
# Usage: show_terminal_notification <message> <type> [duration]
# Types: info, success, warning, error
show_terminal_notification() {
    local message="$1"
    local type="${2:-info}"
    local duration="${3:-3}"
    
    local icon color box_char
    case "$type" in
        success)
            icon="✓"
            color="${GREEN:-\033[0;32m}"
            box_char="═"
            ;;
        warning)
            icon="⚠"
            color="${YELLOW:-\033[1;33m}"
            box_char="═"
            ;;
        error)
            icon="✗"
            color="${RED:-\033[0;31m}"
            box_char="═"
            ;;
        *)
            icon="ℹ"
            color="${CYAN:-\033[0;36m}"
            box_char="─"
            ;;
    esac
    
    local NC="${NC:-\033[0m}"
    
    # Calculate message length for box
    local msg_len=${#message}
    local box_width=$((msg_len + 6))
    
    # Save cursor position
    tput sc 2>/dev/null || true
    
    # Move to top of screen
    tput cup 0 0 2>/dev/null || true
    
    # Print notification box
    echo -ne "${color}"
    printf "╔"
    printf "%${box_width}s" | tr ' ' "$box_char"
    printf "╗\n"
    printf "║ ${icon} ${message} ║\n"
    printf "╚"
    printf "%${box_width}s" | tr ' ' "$box_char"
    printf "╝${NC}\n"
    
    # Restore cursor position
    tput rc 2>/dev/null || true
    
    # Add to history
    add_to_notification_history "Terminal" "$message" "terminal" "$type"
    
    # Auto-hide after duration
    if [[ $duration -gt 0 ]]; then
        (
            sleep "$duration"
            tput sc 2>/dev/null || true
            tput cup 0 0 2>/dev/null || true
            tput ed 2>/dev/null || true
            tput rc 2>/dev/null || true
        ) &
    fi
}

# show_success_banner() - Show success banner
# Usage: show_success_banner <message> [duration]
show_success_banner() {
    show_terminal_notification "$1" "success" "${2:-3}"
}

# show_warning_banner() - Show warning banner
# Usage: show_warning_banner <message> [duration]
show_warning_banner() {
    show_terminal_notification "$1" "warning" "${2:-3}"
}

# show_error_banner() - Show error banner
# Usage: show_error_banner <message> [duration]
show_error_banner() {
    show_terminal_notification "$1" "error" "${2:-3}"
}

# show_info_banner() - Show info banner
# Usage: show_info_banner <message> [duration]
show_info_banner() {
    show_terminal_notification "$1" "info" "${2:-3}"
}

# =============================================================================
# Sound Notification Functions
# =============================================================================

# play_notification_sound() - Play notification sound
# Usage: play_notification_sound [type]
# Types: info, success, warning, error
play_notification_sound() {
    local type="${1:-info}"
    
    if [[ "$ENABLE_SOUND_NOTIFICATIONS" != "true" ]]; then
        return 0
    fi
    
    # Try different sound players
    local sound_file=""
    case "$type" in
        success)
            sound_file="/usr/share/sounds/freedesktop/stereo/complete.oga"
            ;;
        warning)
            sound_file="/usr/share/sounds/freedesktop/stereo/dialog-warning.oga"
            ;;
        error)
            sound_file="/usr/share/sounds/freedesktop/stereo/dialog-error.oga"
            ;;
        *)
            sound_file="/usr/share/sounds/freedesktop/stereo/message.oga"
            ;;
    esac
    
    # Play sound if file exists
    if [[ -f "$sound_file" ]]; then
        if command -v paplay &>/dev/null; then
            paplay "$sound_file" &>/dev/null &
        elif command -v aplay &>/dev/null; then
            aplay "$sound_file" &>/dev/null &
        elif command -v ffplay &>/dev/null; then
            ffplay -nodisp -autoexit "$sound_file" &>/dev/null &
        fi
    fi
}

# =============================================================================
# Notification History Functions
# =============================================================================

# add_to_notification_history() - Add notification to history
# Usage: add_to_notification_history <title> <message> <channel> <type>
add_to_notification_history() {
    local title="$1"
    local message="$2"
    local channel="$3"
    local type="$4"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    local entry="$timestamp|$channel|$type|$title|$message"
    
    NOTIFICATION_HISTORY+=("$entry")
    
    # Limit history size
    if [[ ${#NOTIFICATION_HISTORY[@]} -gt $MAX_NOTIFICATION_HISTORY ]]; then
        NOTIFICATION_HISTORY=("${NOTIFICATION_HISTORY[@]:1}")
    fi
}

# get_notification_history() - Get notification history
# Usage: get_notification_history [count]
# Returns: Last N notifications (default: 10)
get_notification_history() {
    local count="${1:-10}"
    local total=${#NOTIFICATION_HISTORY[@]}
    local start=$((total - count))
    
    if [[ $start -lt 0 ]]; then
        start=0
    fi
    
    for ((i=start; i<total; i++)); do
        echo "${NOTIFICATION_HISTORY[$i]}"
    done
}

# show_notification_history() - Display notification history
# Usage: show_notification_history [count]
show_notification_history() {
    local count="${1:-10}"
    
    echo "=== Notification History (Last $count) ==="
    echo ""
    
    local history
    history=$(get_notification_history "$count")
    
    if [[ -z "$history" ]]; then
        echo "No notifications in history"
        return
    fi
    
    while IFS='|' read -r timestamp channel type title message; do
        local icon
        case "$type" in
            success) icon="✓" ;;
            warning) icon="⚠" ;;
            error) icon="✗" ;;
            *) icon="ℹ" ;;
        esac
        
        echo "[$timestamp] [$channel] $icon $title: $message"
    done <<< "$history"
}

# clear_notification_history() - Clear notification history
clear_notification_history() {
    NOTIFICATION_HISTORY=()
}

# =============================================================================
# Combined Notification Functions
# =============================================================================

# notify() - Send notification to all enabled channels
# Usage: notify <title> <message> <type>
# Types: info, success, warning, error
notify() {
    local title="$1"
    local message="$2"
    local type="${3:-info}"
    
    # Desktop notification
    if [[ "$ENABLE_DESKTOP_NOTIFICATIONS" == "true" ]]; then
        case "$type" in
            success)
                send_success_notification "$title" "$message"
                ;;
            warning)
                send_warning_notification "$title" "$message"
                ;;
            error)
                send_error_notification "$title" "$message"
                ;;
            *)
                send_notification "$title" "$message" "normal" "dialog-information"
                ;;
        esac
    fi
    
    # Terminal notification
    show_terminal_notification "$message" "$type" 3
}

# notify_script_start() - Notify script execution start
# Usage: notify_script_start <script_name>
notify_script_start() {
    local script_name="$1"
    notify "Bashmenu" "Executing: $script_name" "info"
}

# notify_script_success() - Notify script execution success
# Usage: notify_script_success <script_name>
notify_script_success() {
    local script_name="$1"
    notify "Bashmenu" "Completed: $script_name" "success"
}

# notify_script_error() - Notify script execution error
# Usage: notify_script_error <script_name> <error_message>
notify_script_error() {
    local script_name="$1"
    local error_message="${2:-Unknown error}"
    notify "Bashmenu Error" "Failed: $script_name - $error_message" "error"
}

# =============================================================================
# Progress Notification Functions
# =============================================================================

# notify_progress() - Show progress notification
# Usage: notify_progress <title> <percentage>
notify_progress() {
    local title="$1"
    local percentage="$2"
    
    if is_notify_send_available && [[ "$ENABLE_DESKTOP_NOTIFICATIONS" == "true" ]]; then
        notify-send \
            --urgency=low \
            --icon=dialog-information \
            --hint=int:value:"$percentage" \
            "$title" \
            "Progress: $percentage%" \
            2>/dev/null
    fi
}

# =============================================================================
# Initialization
# =============================================================================

# Auto-detect notify-send on module load
detect_notify_send

# =============================================================================
# Export Functions
# =============================================================================

export -f detect_notify_send
export -f is_notify_send_available
export -f send_notification
export -f send_success_notification
export -f send_warning_notification
export -f send_error_notification
export -f show_terminal_notification
export -f show_success_banner
export -f show_warning_banner
export -f show_error_banner
export -f show_info_banner
export -f play_notification_sound
export -f add_to_notification_history
export -f get_notification_history
export -f show_notification_history
export -f clear_notification_history
export -f notify
export -f notify_script_start
export -f notify_script_success
export -f notify_script_error
export -f notify_progress
