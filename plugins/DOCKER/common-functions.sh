#!/bin/bash
#
# Common Functions Library for Docker Scripts
# Version: 1.0.0
# Description: Shared utility functions for all Docker management scripts
#
# This file contains reusable functions that can be sourced by other scripts.
# Each script can also embed these functions directly for independence.

# ============================================================================
# CONFIGURATION AND CONSTANTS
# ============================================================================

# ANSI Color Codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Timeouts (in seconds)
readonly DOCKER_TIMEOUT=30
readonly COMMAND_TIMEOUT=60
readonly BUILD_TIMEOUT=300

# Retry Configuration
readonly MAX_RETRIES=3
readonly RETRY_DELAY=2

# Loop Prevention
declare -g ITERATION_COUNT=0
readonly MAX_ITERATIONS=10

# Exit Codes
readonly EXIT_SUCCESS=0
readonly EXIT_DOCKER_ERROR=1
readonly EXIT_USER_CANCEL=2
readonly EXIT_VALIDATION_ERROR=3
readonly EXIT_TIMEOUT=4

# ============================================================================
# COLOR OUTPUT FUNCTIONS
# ============================================================================

# Print success message in green
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print error message in red
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Print warning message in yellow
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Print info message in blue
print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Print header message in cyan
print_header() {
    echo -e "${CYAN}═══ $1 ═══${NC}"
}

# Print a separator line
print_separator() {
    echo "────────────────────────────────────────────────────────────────"
}

# ============================================================================
# DOCKER VALIDATION FUNCTIONS
# ============================================================================

# Check if Docker daemon is available and responding
# Returns: 0 if Docker is available, 1 otherwise
check_docker() {
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker info &>/dev/null; then
            return 0
        fi
        print_warning "Docker daemon not responding (attempt $attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
    
    print_error "Docker daemon is not available"
    print_info "Please ensure Docker is running: systemctl status docker"
    return 1
}

# Check if Docker daemon is available and exit if not
# This is a convenience function that exits the script on failure
check_docker_or_exit() {
    if ! check_docker; then
        exit $EXIT_DOCKER_ERROR
    fi
}

# ============================================================================
# INPUT VALIDATION FUNCTIONS
# ============================================================================

# Validate that a value is not empty
# Args: $1 = value, $2 = field name
# Returns: 0 if valid, 1 if empty
validate_not_empty() {
    local value="$1"
    local field_name="$2"
    
    if [[ -z "$value" ]]; then
        print_error "$field_name cannot be empty"
        return 1
    fi
    return 0
}

# Validate port number
# Args: $1 = port number
# Returns: 0 if valid, 1 if invalid
validate_port() {
    local port="$1"
    
    if [[ ! "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        print_error "Invalid port: $port (must be between 1 and 65535)"
        return 1
    fi
    return 0
}

# Validate image name format
# Args: $1 = image name
# Returns: 0 if valid, 1 if invalid
validate_image_name() {
    local image_name="$1"
    
    # Basic validation: alphanumeric, hyphens, underscores, slashes, colons, dots
    if [[ ! "$image_name" =~ ^[a-zA-Z0-9._/-]+(:[ a-zA-Z0-9._-]+)?$ ]]; then
        print_error "Invalid image name format: $image_name"
        return 1
    fi
    return 0
}

# Validate container name format
# Args: $1 = container name
# Returns: 0 if valid, 1 if invalid
validate_container_name() {
    local container_name="$1"
    
    # Container names: alphanumeric, hyphens, underscores
    if [[ ! "$container_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Invalid container name format: $container_name"
        print_info "Use only letters, numbers, hyphens, and underscores"
        return 1
    fi
    return 0
}

# ============================================================================
# INTERACTIVE SELECTION MENU
# ============================================================================

# Show an interactive selection menu
# Args: $1 = array name (passed by reference), $2 = prompt message
# Returns: Selected index (0 for cancel, 1-N for items)
# Prints: Selected index to stdout
show_selection_menu() {
    local -n items=$1
    local prompt="$2"
    
    # Check if array is empty
    if [ ${#items[@]} -eq 0 ]; then
        print_warning "No items available for selection"
        return 1
    fi
    
    # Display menu
    print_info "$prompt"
    for i in "${!items[@]}"; do
        echo "  $((i+1))) ${items[$i]}"
    done
    echo "  0) Cancel"
    
    # Get user selection
    local selection
    local max_attempts=5
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        read -p "Select an option: " selection
        
        # Validate selection
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 0 ] && [ "$selection" -le "${#items[@]}" ]; then
            echo "$selection"
            return 0
        fi
        
        print_error "Invalid option. Please select a number between 0 and ${#items[@]}"
        ((attempt++))
    done
    
    print_error "Too many invalid attempts"
    return 1
}

# ============================================================================
# RETRY AND TIMEOUT FUNCTIONS
# ============================================================================

# Execute a command with retry logic
# Args: $@ = command to execute
# Returns: 0 if command succeeds, 1 if all retries fail
retry_command() {
    local max_attempts=$MAX_RETRIES
    local timeout=$COMMAND_TIMEOUT
    local attempt=1
    local cmd="$@"
    
    while [ $attempt -le $max_attempts ]; do
        print_info "Executing: $cmd (attempt $attempt/$max_attempts)"
        
        if timeout $timeout bash -c "$cmd" 2>&1; then
            print_success "Command succeeded"
            return 0
        fi
        
        print_warning "Attempt $attempt/$max_attempts failed"
        ((attempt++))
        
        # Sleep before retry (except after last attempt)
        if [ $attempt -le $max_attempts ]; then
            sleep $RETRY_DELAY
        fi
    done
    
    print_error "Command failed after $max_attempts attempts"
    return 1
}

# Execute a Docker command with timeout
# Args: $1 = timeout in seconds, $@ = docker command
# Returns: 0 if successful, 1 if timeout or failure
docker_command_with_timeout() {
    local timeout_seconds=$1
    shift
    local cmd="docker $@"
    
    if timeout $timeout_seconds $cmd 2>&1; then
        return 0
    else
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            print_error "Command timed out after ${timeout_seconds}s"
        else
            print_error "Command failed with exit code $exit_code"
        fi
        return 1
    fi
}

# ============================================================================
# LOOP PREVENTION
# ============================================================================

# Check for potential infinite loops
# Increments a global counter and exits if threshold is exceeded
# Returns: 0 if OK, exits script if loop detected
check_loop() {
    ((ITERATION_COUNT++))
    
    if [ $ITERATION_COUNT -gt $MAX_ITERATIONS ]; then
        print_error "Detected possible infinite loop (${ITERATION_COUNT} iterations)"
        print_error "Aborting for safety"
        exit $EXIT_TIMEOUT
    fi
    
    return 0
}

# Reset the loop counter
reset_loop_counter() {
    ITERATION_COUNT=0
}

# ============================================================================
# CONFIRMATION FUNCTIONS
# ============================================================================

# Ask for user confirmation (yes/no)
# Args: $1 = prompt message
# Returns: 0 for yes, 1 for no
confirm() {
    local prompt="$1"
    local response
    
    while true; do
        read -p "$prompt (yes/no): " response
        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                return 0
                ;;
            [Nn]|[Nn][Oo])
                return 1
                ;;
            *)
                print_error "Please answer 'yes' or 'no'"
                ;;
        esac
    done
}

# Confirm destructive action with explicit typing
# Args: $1 = action description, $2 = confirmation word (default: "DELETE")
# Returns: 0 if confirmed, 1 if cancelled
confirm_destructive_action() {
    local action="$1"
    local confirm_word="${2:-DELETE}"
    local response
    
    print_warning "DESTRUCTIVE ACTION: $action"
    print_info "Type '$confirm_word' to confirm, or anything else to cancel"
    read -p "> " response
    
    if [ "$response" = "$confirm_word" ]; then
        return 0
    else
        print_info "Action cancelled"
        return 1
    fi
}

# ============================================================================
# ERROR HANDLING
# ============================================================================

# Handle errors with context
# Args: $1 = error code, $2 = error message, $3 = context (optional)
handle_error() {
    local error_code=$1
    local error_msg="$2"
    local context="${3:-}"
    
    case $error_code in
        $EXIT_DOCKER_ERROR)
            print_error "Docker error: $error_msg"
            print_info "Check Docker is running: systemctl status docker"
            ;;
        $EXIT_VALIDATION_ERROR)
            print_error "Validation error: $error_msg"
            if [ -n "$context" ]; then
                print_info "Context: $context"
            fi
            ;;
        $EXIT_TIMEOUT)
            print_error "Operation exceeded time limit: $error_msg"
            print_info "Try again or check system status"
            ;;
        $EXIT_USER_CANCEL)
            print_info "Operation cancelled by user"
            ;;
        *)
            print_error "Unknown error: $error_msg"
            ;;
    esac
    
    return $error_code
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

# Default cleanup function (can be overridden by scripts)
cleanup() {
    print_info "Cleaning up resources..."
    # Scripts should override this with their specific cleanup logic
}

# Setup trap handlers for cleanup
setup_traps() {
    trap cleanup EXIT
    trap 'print_warning "Interrupted by user"; cleanup; exit $EXIT_USER_CANCEL' INT TERM
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Check if a command exists
# Args: $1 = command name
# Returns: 0 if exists, 1 if not
command_exists() {
    command -v "$1" &>/dev/null
}

# Get current timestamp for logging
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Format bytes to human-readable size
# Args: $1 = size in bytes
format_bytes() {
    local bytes=$1
    
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B"
    elif [ $bytes -lt 1048576 ]; then
        echo "$(( bytes / 1024 ))KB"
    elif [ $bytes -lt 1073741824 ]; then
        echo "$(( bytes / 1048576 ))MB"
    else
        echo "$(( bytes / 1073741824 ))GB"
    fi
}

# ============================================================================
# INITIALIZATION
# ============================================================================

# Initialize common functions (call this at the start of scripts)
init_common_functions() {
    # Set bash strict mode
    set -euo pipefail
    
    # Setup trap handlers
    setup_traps
    
    # Reset loop counter
    reset_loop_counter
}

# ============================================================================
# END OF COMMON FUNCTIONS
# ============================================================================
