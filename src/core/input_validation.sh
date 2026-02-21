#!/bin/bash
# =============================================================================
# Input Validation Module for Bashmenu
# =============================================================================
# Description: Comprehensive input validation functions
# Version:     1.0
# Author:      Security Team
# =============================================================================

# Strict mode for security
set -euo pipefail

# =============================================================================
# Validation Functions
# =============================================================================

# Validate alphanumeric input
validate_alphanumeric() {
    local input="$1"
    local field_name="${2:-input}"
    
    if [[ -z "$input" ]]; then
        echo "Error: $field_name cannot be empty"
        return 1
    fi
    
    if [[ ! "$input" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Error: $field_name can only contain letters, numbers, hyphens, and underscores"
        return 1
    fi
    
    if [[ ${#input} -gt 255 ]]; then
        echo "Error: $field_name cannot exceed 255 characters"
        return 1
    fi
    
    return 0
}

# Validate file path with security checks
validate_file_path() {
    local path="$1"
    local field_name="${2:-path}"
    
    if [[ -z "$path" ]]; then
        echo "Error: $field_name cannot be empty"
        return 1
    fi
    
    # Check for dangerous patterns
    if [[ "$path" =~ \.\./ ]] || [[ "$path" =~ \./ ]]; then
        echo "Error: $field_name contains dangerous path traversal patterns"
        return 1
    fi
    
    # Check for absolute paths (only allow relative to project)
    if [[ "$path" =~ ^/ ]]; then
        echo "Error: $field_name must be a relative path"
        return 1
    fi
    
    # Check for dangerous characters
    if [[ "$path" =~ [\;\|\&\$\`\<\>\"\'\\] ]]; then
        echo "Error: $field_name contains dangerous characters"
        return 1
    fi
    
    # Check path length
    if [[ ${#path} -gt 4096 ]]; then
        echo "Error: $field_name path too long"
        return 1
    fi
    
    return 0
}

# Validate positive integer
validate_positive_integer() {
    local input="$1"
    local field_name="${2:-number}"
    
    if [[ -z "$input" ]]; then
        echo "Error: $field_name cannot be empty"
        return 1
    fi
    
    if [[ ! "$input" =~ ^[0-9]+$ ]]; then
        echo "Error: $field_name must be a positive integer"
        return 1
    fi
    
    if [[ "$input" -gt 1000000 ]]; then
        echo "Error: $field_name exceeds maximum allowed value"
        return 1
    fi
    
    return 0
}

# Validate URL format
validate_url() {
    local url="$1"
    local field_name="${2:-URL}"
    
    if [[ -z "$url" ]]; then
        echo "Error: $field_name cannot be empty"
        return 1
    fi
    
    # Basic URL validation
    if [[ ! "$url" =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]; then
        echo "Error: $field_name is not a valid URL format"
        return 1
    fi
    
    if [[ ${#url} -gt 2048 ]]; then
        echo "Error: $field_name URL too long"
        return 1
    fi
    
    return 0
}

# Validate email format
validate_email() {
    local email="$1"
    local field_name="${2:-email}"
    
    if [[ -z "$email" ]]; then
        echo "Error: $field_name cannot be empty"
        return 1
    fi
    
    # Basic email validation
    if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "Error: $field_name is not a valid email format"
        return 1
    fi
    
    if [[ ${#email} -gt 254 ]]; then
        echo "Error: $field_name email too long"
        return 1
    fi
    
    return 0
}

# Validate script name
validate_script_name() {
    local name="$1"
    local field_name="${2:-script name}"
    
    if [[ -z "$name" ]]; then
        echo "Error: $field_name cannot be empty"
        return 1
    fi
    
    # Script names should be safe for function creation
    if [[ ! "$name" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
        echo "Error: $field_name must start with a letter and contain only letters, numbers, hyphens, and underscores"
        return 1
    fi
    
    if [[ ${#name} -gt 64 ]]; then
        echo "Error: $field_name cannot exceed 64 characters"
        return 1
    fi
    
    return 0
}

# Sanitize input for safe use
sanitize_input() {
    local input="$1"
    
    # Remove dangerous characters
    input="${input//[\;\|\&\$\`\<\>\"\'\\]/}"
    
    # Remove control characters
    input=$(echo "$input" | tr -d '\000-\010\013\014\016-\037\177-\377')
    
    # Trim whitespace
    input="${input#"${input%%[![:space:]]*}"}"
    input="${input%"${input##*[![:space:]]}"}"
    
    echo "$input"
}

# Validate port number
validate_port() {
    local port="$1"
    local field_name="${2:-port}"
    
    if ! validate_positive_integer "$port" "$field_name"; then
        return 1
    fi
    
    if [[ "$port" -lt 1 ]] || [[ "$port" -gt 65535 ]]; then
        echo "Error: $field_name must be between 1 and 65535"
        return 1
    fi
    
    return 0
}

# Validate IP address (IPv4 only)
validate_ipv4() {
    local ip="$1"
    local field_name="${2:-IP address}"
    
    if [[ -z "$ip" ]]; then
        echo "Error: $field_name cannot be empty"
        return 1
    fi
    
    # IPv4 validation
    if [[ ! "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo "Error: $field_name is not a valid IPv4 address"
        return 1
    fi
    
    # Check each octet
    IFS='.' read -ra ADDR <<< "$ip"
    for i in "${ADDR[@]}"; do
        if [[ "$i" -gt 255 ]] || [[ "$i" -lt 0 ]]; then
            echo "Error: $field_name contains invalid octet: $i"
            return 1
        fi
    done
    
    return 0
}

# Export all validation functions
export -f validate_alphanumeric
export -f validate_file_path
export -f validate_positive_integer
export -f validate_url
export -f validate_email
export -f validate_script_name
export -f sanitize_input
export -f validate_port
export -f validate_ipv4