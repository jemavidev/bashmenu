#!/bin/bash

# =============================================================================
# Logging System for Bashmenu
# =============================================================================
# Description: Comprehensive logging system with multiple levels and file output
# Version:     1.0
# =============================================================================

# =============================================================================
# Log Levels
# =============================================================================

readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3

# =============================================================================
# Helper Functions
# =============================================================================

# Get current log level from config
get_log_level() {
    echo "${LOG_LEVEL:-1}"
}

# Write to log file
write_log() {
    local level="$1"
    local message="$2"
    local log_file="${LOG_FILE:-/tmp/bashmenu.log}"
    
    # Create log directory if it doesn't exist
    local log_dir=$(dirname "$log_file")
    mkdir -p "$log_dir" 2>/dev/null
    
    # Format: [YYYY-MM-DD HH:MM:SS] [LEVEL] message
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$log_file" 2>/dev/null
}

# =============================================================================
# Logging Functions
# =============================================================================

log_debug() {
    local current_level=$(get_log_level)
    if [[ $current_level -le $LOG_LEVEL_DEBUG ]]; then
        # Only output to stderr in debug mode
        if [[ "${DEBUG_MODE:-false}" == "true" ]]; then
            echo -e "[DEBUG] $*" >&2
        fi
        write_log "DEBUG" "$*"
    fi
}

log_info() {
    local current_level=$(get_log_level)
    if [[ $current_level -le $LOG_LEVEL_INFO ]]; then
        # Only output to stderr in debug mode
        if [[ "${DEBUG_MODE:-false}" == "true" ]]; then
            echo -e "[INFO] $*" >&2
        fi
        write_log "INFO" "$*"
    fi
}

log_warn() {
    local current_level=$(get_log_level)
    if [[ $current_level -le $LOG_LEVEL_WARN ]]; then
        # Only output to stderr in debug mode
        if [[ "${DEBUG_MODE:-false}" == "true" ]]; then
            echo -e "[WARN] $*" >&2
        fi
        write_log "WARN" "$*"
    fi
}

log_error() {
    local current_level=$(get_log_level)
    if [[ $current_level -le $LOG_LEVEL_ERROR ]]; then
        # Only output to stderr in debug mode
        if [[ "${DEBUG_MODE:-false}" == "true" ]]; then
            echo -e "[ERROR] $*" >&2
        fi
        write_log "ERROR" "$*"
    fi
}

# Log command execution
log_command() {
    local user=$(whoami)
    local command="$1"
    local status="$2"
    
    if [[ "${ENABLE_HISTORY:-true}" == "true" ]]; then
        local history_file="${HISTORY_FILE:-$HOME/.bashmenu_history.log}"
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        mkdir -p "$(dirname "$history_file")" 2>/dev/null
        echo "[$timestamp] [$user] $command - Status: $status" >> "$history_file" 2>/dev/null
    fi
    
    log_info "User $user executed: $command (Status: $status)"
}

# =============================================================================
# Export Functions
# =============================================================================

export -f log_debug
export -f log_info
export -f log_warn
export -f log_error
export -f log_command
export -f get_log_level
export -f write_log
