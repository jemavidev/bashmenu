#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Menu Validation - Bashmenu
# =============================================================================
# Description: Script validation and security checks
# Version:     3.0
# Author:      JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Path Sanitization Functions
# =============================================================================

# sanitize_script_path() -> string
# Sanitize script path to prevent directory traversal
# Args:
#   $1 - Path to sanitize
# Returns: Sanitized path or empty string on failure
sanitize_script_path() {
    local path="$1"
    
    # Input validation
    if [[ -z "$path" ]]; then
        echo ""
        return 1
    fi
    
    # Reject dangerous patterns first
    if [[ "$path" =~ \.\./ ]] || [[ "$path" =~ \./ ]]; then
        echo ""
        return 1
    fi
    
    # Remove any remaining dangerous sequences (defense in depth)
    path="${path//\.\.\//}"
    path="${path//.\//}"
    path="${path//..\/}"
    path="${path//.\//}"
    
    # Remove multiple consecutive slashes
    path="${path//\/\//\/}"
    
    # Remove trailing slash
    path="${path%/}"
    
    # Validate final path doesn't contain dangerous patterns
    if [[ "$path" =~ \.\./ ]] || [[ "$path" =~ \./ ]]; then
        echo ""
        return 1
    fi
    
    echo "$path"
}

# =============================================================================
# Script Path Validation Functions
# =============================================================================

# validate_script_path() -> int
# Validate external script path with comprehensive security checks
# Args:
#   $1 - Script path to validate
# Returns: 0 if valid, 1 if invalid
validate_script_path() {
    local script_path="$1"
    local validation_errors=0
    
    if declare -f log_debug >/dev/null; then
        log_debug "Validating script path: $script_path"
    fi
    
    # Sanitize the path first
    local sanitized_path=$(sanitize_script_path "$script_path")
    
    # Check if path changed after sanitization (potential attack)
    if [[ "$script_path" != "$sanitized_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script path contains suspicious characters: $script_path"
        fi
        print_error "Script path validation failed: suspicious path"
        return 1
    fi
    
    # Validate path is absolute
    if ! validate_absolute_path "$script_path"; then
        validation_errors=$((validation_errors + 1))
    fi
    
    # Validate path exists
    if ! validate_path_exists "$script_path"; then
        validation_errors=$((validation_errors + 1))
    fi
    
    # Validate it's a regular file
    if ! validate_regular_file "$script_path"; then
        validation_errors=$((validation_errors + 1))
    fi
    
    # Validate file is readable
    if ! validate_file_readable "$script_path"; then
        validation_errors=$((validation_errors + 1))
    fi
    
    # Validate file is executable
    if ! validate_file_executable "$script_path"; then
        validation_errors=$((validation_errors + 1))
    fi
    
    # Handle symbolic links
    if ! validate_symbolic_link "$script_path"; then
        validation_errors=$((validation_errors + 1))
    fi
    
    # Validate against allowed directories
    if ! validate_allowed_directory "$script_path"; then
        validation_errors=$((validation_errors + 1))
    fi
    
    # Return validation result
    if [[ $validation_errors -gt 0 ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script validation failed with $validation_errors error(s): $script_path"
        fi
        return 1
    fi
    
    if declare -f log_info >/dev/null; then
        log_info "Script validation passed: $script_path"
    fi
    
    return 0
}

# =============================================================================
# Individual Validation Checks
# =============================================================================

# validate_absolute_path() -> int
# Check if path is absolute
validate_absolute_path() {
    local script_path="$1"
    
    if [[ ! "$script_path" =~ ^/ ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script path must be absolute: $script_path"
        fi
        print_error "Script path must be absolute"
        return 1
    fi
    return 0
}

# validate_path_exists() -> int
# Check if path exists
validate_path_exists() {
    local script_path="$1"
    
    if [[ ! -e "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script path does not exist: $script_path"
        fi
        print_error "Script file not found: $script_path"
        return 1
    fi
    return 0
}

# validate_regular_file() -> int
# Check if it's a regular file
validate_regular_file() {
    local script_path="$1"
    
    if [[ -e "$script_path" ]] && [[ ! -f "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script path is not a regular file: $script_path"
        fi
        print_error "Script path must be a regular file"
        return 1
    fi
    return 0
}

# validate_file_readable() -> int
# Check if file is readable
validate_file_readable() {
    local script_path="$1"
    
    if [[ -f "$script_path" ]] && [[ ! -r "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script file is not readable: $script_path"
        fi
        print_error "Script file is not readable"
        return 1
    fi
    return 0
}

# validate_file_executable() -> int
# Check if file is executable
validate_file_executable() {
    local script_path="$1"
    
    if [[ -f "$script_path" ]] && [[ ! -x "$script_path" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script file is not executable: $script_path"
        fi
        print_error "Script file is not executable: $script_path"
        return 1
    fi
    return 0
}

# validate_symbolic_link() -> int
# Handle symbolic links
validate_symbolic_link() {
    local script_path="$1"
    
    if [[ -L "$script_path" ]]; then
        if declare -f log_warn >/dev/null; then
            log_warn "Script path is a symbolic link: $script_path"
        fi
        
        # Resolve the symbolic link
        local real_path=$(readlink -f "$script_path" 2>/dev/null)
        if [[ -z "$real_path" ]]; then
            if declare -f log_error >/dev/null; then
                log_error "Failed to resolve symbolic link: $script_path"
            fi
            print_error "Failed to resolve symbolic link"
            return 1
        else
            if declare -f log_info >/dev/null; then
                log_info "Symbolic link resolves to: $real_path"
            fi
        fi
    fi
    return 0
}

# validate_allowed_directory() -> int
# Check if path is within allowed directories
validate_allowed_directory() {
    local script_path="$1"
    
    # Check if path is within allowed directories (if configured)
    if [[ -z "${ALLOWED_SCRIPT_DIRS:-}" ]]; then
        return 0  # No restrictions configured
    fi
    
    local is_allowed=false
    local canonical_script_path=$(readlink -f "$script_path" 2>/dev/null || echo "$script_path")
    
    # Parse allowed directories (colon-separated)
    IFS=':' read -ra allowed_dirs <<< "$ALLOWED_SCRIPT_DIRS"
    
    if declare -f log_debug >/dev/null; then
        log_debug "Checking against allowed directories: ${ALLOWED_SCRIPT_DIRS}"
    fi
    
    for dir in "${allowed_dirs[@]}"; do
        # Skip empty entries
        [[ -z "$dir" ]] && continue
        
        # Get canonical path of allowed directory
        local canonical_dir=$(readlink -f "$dir" 2>/dev/null || echo "$dir")
        
        # Check if script is within this directory
        if [[ "$canonical_script_path" == "$canonical_dir"* ]]; then
            is_allowed=true
            if declare -f log_debug >/dev/null; then
                log_debug "Script is within allowed directory: $canonical_dir"
            fi
            break
        fi
    done
    
    if [[ "$is_allowed" == "false" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "Script path not in allowed directories: $script_path"
        fi
        print_error "Script path not in allowed directories"
        print_info "Allowed directories: ${ALLOWED_SCRIPT_DIRS}"
        return 1
    fi
    
    return 0
}

# =============================================================================
# Export Functions
# =============================================================================

export -f sanitize_script_path
export -f validate_script_path
export -f validate_absolute_path
export -f validate_path_exists
export -f validate_regular_file
export -f validate_file_readable
export -f validate_file_executable
export -f validate_symbolic_link
export -f validate_allowed_directory
