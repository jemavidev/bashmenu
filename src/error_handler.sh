#!/bin/bash

# =============================================================================
# Error Handling and Recovery Module for Bashmenu
# =============================================================================
# Description: Comprehensive error handling, logging, and recovery mechanisms
# Version:     1.0
# =============================================================================

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Global Error Handling Variables
# =============================================================================

# Error codes
readonly ERROR_SUCCESS=0
readonly ERROR_GENERAL=1
readonly ERROR_INVALID_INPUT=2
readonly ERROR_FILE_NOT_FOUND=3
readonly ERROR_PERMISSION_DENIED=4
readonly ERROR_NETWORK_ERROR=5
readonly ERROR_TIMEOUT=6
readonly ERROR_SCRIPT_EXECUTION=7
readonly ERROR_VALIDATION_FAILED=8
readonly ERROR_MEMORY_EXHAUSTED=9
readonly ERROR_DISK_FULL=10

# Error state tracking
declare -A ERROR_CONTEXT
declare -A ERROR_RECOVERY_ACTIONS
ERROR_COUNT=0
LAST_ERROR_CODE=0
LAST_ERROR_MESSAGE=""

# =============================================================================
# Error Handler Functions
# =============================================================================

# Global error trap
setup_error_trap() {
    trap 'handle_error $? $LINENO "$BASH_COMMAND" "$BASH_SOURCE"' ERR
    trap 'handle_exit $? $LINENO' EXIT
    trap 'handle_interrupt' INT TERM
}

# Handle errors that occur in the script
handle_error() {
    local exit_code=$1
    local line_number=$2
    local bash_command="$3"
    local bash_source="$4"
    
    # Skip if this is an intended exit
    if [[ $exit_code -eq 0 ]]; then
        return 0
    fi
    
    ERROR_COUNT=$((ERROR_COUNT + 1))
    LAST_ERROR_CODE=$exit_code
    LAST_ERROR_MESSAGE="Command '$bash_command' failed with exit code $exit_code at line $line_number in $bash_source"
    
    # Store error context
    ERROR_CONTEXT["timestamp"]="$(date '+%Y-%m-%d %H:%M:%S')"
    ERROR_CONTEXT["exit_code"]=$exit_code
    ERROR_CONTEXT["line_number"]=$line_number
    ERROR_CONTEXT["bash_command"]="$bash_command"
    ERROR_CONTEXT["bash_source"]="$bash_source"
    ERROR_CONTEXT["user"]="$(whoami)"
    ERROR_CONTEXT["hostname"]="$(hostname)"
    
    # Log the error
    if declare -f log_error >/dev/null; then
        log_error "$LAST_ERROR_MESSAGE"
    else
        echo "ERROR: $LAST_ERROR_MESSAGE" >&2
    fi
    
    # Attempt recovery if configured
    if [[ -n "${ERROR_RECOVERY_ACTIONS[$exit_code]:-}" ]]; then
        if declare -f log_info >/dev/null; then
            log_info "Attempting recovery for error code $exit_code"
        fi
        ${ERROR_RECOVERY_ACTIONS[$exit_code]}
    fi
    
    # Show error dialog if available
    if declare -f show_error_dialog >/dev/null && [[ "${INTERACTIVE_MODE:-true}" == "true" ]]; then
        show_error_dialog "$exit_code" "$LAST_ERROR_MESSAGE"
    fi
    
    # Exit or continue based on error severity
    case $exit_code in
        $ERROR_MEMORY_EXHAUSTED|$ERROR_DISK_FULL)
            exit $exit_code
            ;;
        $ERROR_PERMISSION_DENIED)
            # Give user chance to fix permissions
            if [[ "${INTERACTIVE_MODE:-true}" == "true" ]]; then
                echo "Permission denied. Press Enter to continue or Ctrl+C to exit..."
                read -r
                return 0
            else
                exit $exit_code
            fi
            ;;
        *)
            # Continue by default for other errors
            return 0
            ;;
    esac
}

# Handle script exit
handle_exit() {
    local exit_code=$1
    
    # Only log if there was an error
    if [[ $exit_code -ne 0 ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script exiting with error code $exit_code"
        fi
    else
        if declare -f log_info >/dev/null; then
            log_info "Script completed successfully"
        fi
    fi
    
    # Clean up temporary files
    cleanup_on_exit
    
    # Report error statistics
    if [[ $ERROR_COUNT -gt 0 ]] && declare -f log_info >/dev/null; then
        log_info "Total errors encountered: $ERROR_COUNT"
    fi
}

# Handle interrupts (Ctrl+C, etc.)
handle_interrupt() {
    if declare -f log_info >/dev/null; then
        log_info "Script interrupted by user"
    fi
    
    # Clean up before exiting
    cleanup_on_exit
    
    exit 130
}

# =============================================================================
# Recovery Actions
# =============================================================================

# Set up recovery actions for common errors
setup_recovery_actions() {
    ERROR_RECOVERY_ACTIONS[$ERROR_FILE_NOT_FOUND]="recover_file_not_found"
    ERROR_RECOVERY_ACTIONS[$ERROR_PERMISSION_DENIED]="recover_permission_denied"
    ERROR_RECOVERY_ACTIONS[$ERROR_NETWORK_ERROR]="recover_network_error"
    ERROR_RECOVERY_ACTIONS[$ERROR_TIMEOUT]="recover_timeout"
    ERROR_RECOVERY_ACTIONS[$ERROR_SCRIPT_EXECUTION]="recover_script_execution"
}

# Recovery for file not found errors
recover_file_not_found() {
    if declare -f log_info >/dev/null; then
        log_info "File not found - attempting to locate alternative"
    fi
    
    # Try to find the file in common locations
    # This is a placeholder for specific recovery logic
    return 0
}

# Recovery for permission denied errors
recover_permission_denied() {
    if declare -f log_info >/dev/null; then
        log_info "Permission denied - checking alternative access methods"
    fi
    
    # Check if running with sudo would help
    if [[ $EUID -ne 0 ]] && [[ "${AUTO_SUDO_PROMPT:-false}" == "true" ]]; then
        echo "This operation requires root privileges. Attempting with sudo..."
        # This would need to be implemented carefully
    fi
    
    return 0
}

# Recovery for network errors
recover_network_error() {
    if declare -f log_info >/dev/null; then
        log_info "Network error - checking connectivity"
    fi
    
    # Test basic connectivity
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        if declare -f log_info >/dev/null; then
            log_info "Network connectivity restored"
        fi
    else
        if declare -f log_warn >/dev/null; then
            log_warn "Network connectivity issues detected"
        fi
    fi
    
    return 0
}

# Recovery for timeout errors
recover_timeout() {
    if declare -f log_info >/dev/null; then
        log_info "Timeout occurred - increasing timeout and retrying"
    fi
    
    # Increase timeout values
    export TIMEOUT_RETRY_COUNT=$((TIMEOUT_RETRY_COUNT + 1))
    export TIMEOUT_DURATION=$((TIMEOUT_DURATION * 2))
    
    return 0
}

# Recovery for script execution errors
recover_script_execution() {
    if declare -f log_info >/dev/null; then
        log_info "Script execution failed - checking script integrity"
    fi
    
    # Check if the script has proper permissions
    # This would need to be implemented based on the specific script
    
    return 0
}

# =============================================================================
# Utility Functions
# =============================================================================

# Clean up on script exit
cleanup_on_exit() {
    # Remove temporary files
    if [[ -n "${TEMP_DIR:-}" ]] && [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    
    # Kill background processes
    local jobs_list
    jobs_list=$(jobs -p)
    if [[ -n "$jobs_list" ]]; then
        kill $jobs_list 2>/dev/null || true
    fi
    
    # Restore terminal settings if changed
    if [[ -n "${ORIGINAL_STTY:-}" ]]; then
        stty "$ORIGINAL_STTY" 2>/dev/null || true
    fi
}

# Show error dialog (if dialog/whiptail is available)
show_error_dialog() {
    local exit_code=$1
    local error_message="$2"
    
    # Try different dialog methods
    if command -v dialog >/dev/null; then
        dialog --title "Error $exit_code" --msgbox "$error_message" 10 60
    elif command -v whiptail >/dev/null; then
        whiptail --title "Error $exit_code" --msgbox "$error_message" 10 60
    else
        echo ""
        echo "========================================"
        echo "ERROR $exit_code"
        echo "========================================"
        echo "$error_message"
        echo "========================================"
        echo ""
    fi
}

# Check system health before critical operations
check_system_health() {
    local checks_failed=0
    
    # Check disk space
    local disk_usage
    disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ $disk_usage -gt 90 ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Disk space critically low: ${disk_usage}%"
        fi
        checks_failed=$((checks_failed + 1))
    fi
    
    # Check memory usage
    local mem_usage
    mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    if [[ $mem_usage -gt 90 ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Memory usage critically high: ${mem_usage}%"
        fi
        checks_failed=$((checks_failed + 1))
    fi
    
    # Check load average
    local load_avg
    load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    if (( $(echo "$load_avg > 2.0" | bc -l) )); then
        if declare -f log_warn >/dev/null; then
            log_warn "High system load: $load_avg"
        fi
    fi
    
    return $checks_failed
}

# Validate environment before starting
validate_environment() {
    local validation_errors=0
    
    # Check required commands
    local required_commands=("bash" "find" "grep" "awk" "sed")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null; then
            if declare -f log_error >/dev/null; then
                log_error "Required command not found: $cmd"
            fi
            validation_errors=$((validation_errors + 1))
        fi
    done
    
    # Check for proper file permissions
    if [[ ! -r "bashmenu" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Cannot read bashmenu file"
        fi
        validation_errors=$((validation_errors + 1))
    fi
    
    # Check configuration files
    if [[ -f "config/config.conf" ]] && [[ ! -r "config/config.conf" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Cannot read configuration file"
        fi
        validation_errors=$((validation_errors + 1))
    fi
    
    return $validation_errors
}

# Get error statistics
get_error_statistics() {
    echo "Error Statistics:"
    echo "  Total Errors: $ERROR_COUNT"
    echo "  Last Error Code: $LAST_ERROR_CODE"
    echo "  Last Error Message: $LAST_ERROR_MESSAGE"
    
    if [[ ${#ERROR_CONTEXT[@]} -gt 0 ]]; then
        echo "  Error Context:"
        for key in "${!ERROR_CONTEXT[@]}"; do
            echo "    $key: ${ERROR_CONTEXT[$key]}"
        done
    fi
}

# Reset error tracking
reset_error_tracking() {
    ERROR_COUNT=0
    LAST_ERROR_CODE=0
    LAST_ERROR_MESSAGE=""
    ERROR_CONTEXT=()
}

# =============================================================================
# Initialization
# =============================================================================

# Initialize error handling system
initialize_error_handling() {
    # Set up traps
    setup_error_trap
    
    # Set up recovery actions
    setup_recovery_actions
    
    # Store original terminal settings
    ORIGINAL_STTY=$(stty -g 2>/dev/null || echo "")
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d 2>/dev/null || echo "/tmp/bashmenu_$$")
    
    if declare -f log_info >/dev/null; then
        log_info "Error handling system initialized"
    fi
}

# Export all functions and variables
export -f setup_error_trap
export -f handle_error
export -f handle_exit
export -f handle_interrupt
export -f setup_recovery_actions
export -f recover_file_not_found
export -f recover_permission_denied
export -f recover_network_error
export -f recover_timeout
export -f recover_script_execution
export -f cleanup_on_exit
export -f show_error_dialog
export -f check_system_health
export -f validate_environment
export -f get_error_statistics
export -f reset_error_tracking
export -f initialize_error_handling

# Export constants
export ERROR_SUCCESS ERROR_GENERAL ERROR_INVALID_INPUT ERROR_FILE_NOT_FOUND
export ERROR_PERMISSION_DENIED ERROR_NETWORK_ERROR ERROR_TIMEOUT
export ERROR_SCRIPT_EXECUTION ERROR_VALIDATION_FAILED
export ERROR_MEMORY_EXHAUSTED ERROR_DISK_FULL

# Export variables
export -A ERROR_CONTEXT ERROR_RECOVERY_ACTIONS
export ERROR_COUNT LAST_ERROR_CODE LAST_ERROR_MESSAGE
export ORIGINAL_STTY TEMP_DIR