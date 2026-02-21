#!/bin/bash

# =============================================================================
# Bashmenu v2.2 - Configuration Management
# =============================================================================
# Description: Handles .env file loading, validation, and configuration access
# Version:     2.2
# =============================================================================

# =============================================================================
# Global Variables
# =============================================================================

# Configuration loaded flag
declare -g BASHMENU_CONFIG_LOADED=false

# Configuration cache
declare -gA BASHMENU_CONFIG_CACHE

# Default configuration values
declare -gA BASHMENU_DEFAULTS=(
    [BASHMENU_HOME]="/opt/bashmenu"
    [BASHMENU_USER_DIR]="$HOME/.bashmenu"
    [BASHMENU_PLUGINS_DIR]="$HOME/.bashmenu/plugins"
    [BASHMENU_LOG_DIR]="/var/log/bashmenu"
    [BASHMENU_CACHE_DIR]="$HOME/.bashmenu/cache"
    [BASHMENU_THEME]="modern"
    [BASHMENU_LOG_LEVEL]="INFO"
    [BASHMENU_ENABLE_CACHE]="true"
    [BASHMENU_CACHE_TTL]="3600"
    [BASHMENU_ENABLE_COLORS]="true"
    [BASHMENU_ENABLE_PLUGINS]="true"
    [BASHMENU_ENABLE_HISTORY]="true"
    [BASHMENU_DEBUG_MODE]="false"
    [BASHMENU_STRICT_MODE]="true"
)

# =============================================================================
# Configuration File Priority
# =============================================================================
# Priority order (highest to lowest):
# 1. Environment variables (already set)
# 2. ~/.bashmenu/.bashmenu.env (user config)
# 3. /opt/bashmenu/etc/.bashmenu.env (system config)
# 4. Project root .bashmenu.env (development)
# 5. Default values
# =============================================================================

# load_env_file() -> int
# Loads environment variables from a .env file
# Args:
#   $1 - Path to .env file
# Returns:
#   0 on success, 1 on failure
load_env_file() {
    local env_file="$1"
    
    # Check if file exists and is readable
    if [[ ! -f "$env_file" ]]; then
        return 1
    fi
    
    if [[ ! -r "$env_file" ]]; then
        if declare -f log_warn >/dev/null; then
            log_warn "Cannot read config file: $env_file (permission denied)"
        fi
        return 1
    fi
    
    # Validate file syntax before sourcing
    if ! bash -n "$env_file" 2>/dev/null; then
        if declare -f log_error >/dev/null; then
            log_error "Config file has syntax errors: $env_file"
        fi
        return 1
    fi
    
    # Source the file in current shell to set variables
    local line key value
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        # Match KEY=VALUE pattern
        if [[ "$line" =~ ^[[:space:]]*([A-Z_][A-Z0-9_]*)=(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            
            # Remove quotes if present
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"
            
            # Expand variables in value (use eval carefully)
            value=$(eval "echo \"$value\"")
            
            # Only set if not already set in environment
            if [[ -z "${!key:-}" ]]; then
                declare -g "$key=$value"
                export "$key"
                BASHMENU_CONFIG_CACHE["$key"]="$value"
            fi
        fi
    done < "$env_file"
    
    if declare -f log_debug >/dev/null; then
        log_debug "Loaded config from: $env_file"
    fi
    
    return 0
}

# load_configuration() -> int
# Loads configuration from all available sources in priority order
# Returns:
#   0 on success
load_configuration() {
    local config_loaded=false
    local config_files=()
    
    # Determine project root (where bashmenu script is located)
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    
    # Build list of config files to try (in priority order)
    # User config (highest priority after ENV)
    if [[ -f "$HOME/.bashmenu/.bashmenu.env" ]]; then
        config_files+=("$HOME/.bashmenu/.bashmenu.env")
    fi
    
    # System config
    if [[ -f "/opt/bashmenu/etc/.bashmenu.env" ]]; then
        config_files+=("/opt/bashmenu/etc/.bashmenu.env")
    fi
    
    # Development config (project root)
    if [[ -f "$script_dir/.bashmenu.env" ]]; then
        config_files+=("$script_dir/.bashmenu.env")
    fi
    
    # Load config files in reverse order (lowest priority first)
    # This way higher priority files override lower priority ones
    local i
    for (( i=${#config_files[@]}-1; i>=0; i-- )); do
        if load_env_file "${config_files[$i]}"; then
            config_loaded=true
        fi
    done
    
    # Apply default values for any missing configuration
    local key
    for key in "${!BASHMENU_DEFAULTS[@]}"; do
        if [[ -z "${!key:-}" ]]; then
            declare -g "$key=${BASHMENU_DEFAULTS[$key]}"
            export "$key"
            BASHMENU_CONFIG_CACHE["$key"]="${BASHMENU_DEFAULTS[$key]}"
        fi
    done
    
    # Mark configuration as loaded
    declare -g BASHMENU_CONFIG_LOADED=true
    export BASHMENU_CONFIG_LOADED
    
    # Validate critical configuration
    validate_config
    
    if declare -f log_info >/dev/null; then
        if [[ "$config_loaded" == "true" ]]; then
            log_info "Configuration loaded successfully"
        else
            log_info "Using default configuration (no config file found)"
        fi
    fi
    
    return 0
}

# validate_config() -> int
# Validates configuration values and applies corrections
# Returns:
#   0 on success
validate_config() {
    local warnings=0
    
    # Validate boolean values
    local bool_vars=(
        "BASHMENU_ENABLE_CACHE"
        "BASHMENU_ENABLE_COLORS"
        "BASHMENU_ENABLE_PLUGINS"
        "BASHMENU_ENABLE_HISTORY"
        "BASHMENU_DEBUG_MODE"
        "BASHMENU_STRICT_MODE"
        "BASHMENU_ENABLE_SEARCH"
        "BASHMENU_ENABLE_FAVORITES"
        "BASHMENU_ENABLE_HOOKS"
        "BASHMENU_ENABLE_LAZY_LOADING"
        "BASHMENU_ENABLE_JSON_AUDIT"
        "BASHMENU_ENABLE_ANIMATIONS"
        "BASHMENU_ENABLE_NOTIFICATIONS"
        "BASHMENU_ENABLE_FZF"
    )
    
    local var
    for var in "${bool_vars[@]}"; do
        local value="${!var:-}"
        if [[ -n "$value" ]] && [[ "$value" != "true" ]] && [[ "$value" != "false" ]]; then
            if declare -f log_warn >/dev/null; then
                log_warn "Invalid $var value: $value (using default: ${BASHMENU_DEFAULTS[$var]:-true})"
            fi
            declare -g "$var=${BASHMENU_DEFAULTS[$var]:-true}"
            export "$var"
            warnings=$((warnings + 1))
        fi
    done
    
    # Validate log level
    local valid_log_levels=("DEBUG" "INFO" "WARN" "ERROR")
    local log_level_valid=false
    local level
    for level in "${valid_log_levels[@]}"; do
        if [[ "${BASHMENU_LOG_LEVEL:-}" == "$level" ]]; then
            log_level_valid=true
            break
        fi
    done
    
    if [[ "$log_level_valid" == "false" ]]; then
        if declare -f log_warn >/dev/null; then
            log_warn "Invalid BASHMENU_LOG_LEVEL: ${BASHMENU_LOG_LEVEL:-} (using default: INFO)"
        fi
        declare -g BASHMENU_LOG_LEVEL="INFO"
        export BASHMENU_LOG_LEVEL
        warnings=$((warnings + 1))
    fi
    
    # Validate numeric values
    if [[ -n "${BASHMENU_CACHE_TTL:-}" ]] && ! [[ "${BASHMENU_CACHE_TTL}" =~ ^[0-9]+$ ]]; then
        if declare -f log_warn >/dev/null; then
            log_warn "Invalid BASHMENU_CACHE_TTL: ${BASHMENU_CACHE_TTL} (using default: 3600)"
        fi
        declare -g BASHMENU_CACHE_TTL=3600
        export BASHMENU_CACHE_TTL
        warnings=$((warnings + 1))
    fi
    
    # Validate theme
    local valid_themes=("default" "dark" "colorful" "minimal" "modern")
    local theme_valid=false
    local theme
    for theme in "${valid_themes[@]}"; do
        if [[ "${BASHMENU_THEME:-}" == "$theme" ]]; then
            theme_valid=true
            break
        fi
    done
    
    if [[ "$theme_valid" == "false" ]]; then
        if declare -f log_warn >/dev/null; then
            log_warn "Invalid BASHMENU_THEME: ${BASHMENU_THEME:-} (using default: modern)"
        fi
        declare -g BASHMENU_THEME="modern"
        export BASHMENU_THEME
        warnings=$((warnings + 1))
    fi
    
    # Validate directories exist (create if needed)
    local dirs_to_check=(
        "BASHMENU_USER_DIR"
        "BASHMENU_PLUGINS_DIR"
        "BASHMENU_CACHE_DIR"
    )
    
    for var in "${dirs_to_check[@]}"; do
        local dir="${!var:-}"
        if [[ -n "$dir" ]] && [[ ! -d "$dir" ]]; then
            if mkdir -p "$dir" 2>/dev/null; then
                if declare -f log_info >/dev/null; then
                    log_info "Created directory: $dir"
                fi
            else
                if declare -f log_warn >/dev/null; then
                    log_warn "Cannot create directory: $dir"
                fi
                warnings=$((warnings + 1))
            fi
        fi
    done
    
    if [[ $warnings -gt 0 ]]; then
        if declare -f log_warn >/dev/null; then
            log_warn "Configuration validation found $warnings issue(s)"
        fi
    fi
    
    return 0
}

# get_config() -> string
# Gets a configuration value
# Args:
#   $1 - Configuration key
#   $2 - Default value (optional)
# Returns:
#   Configuration value or default
get_config() {
    local key="$1"
    local default="${2:-}"
    
    # Check cache first
    if [[ -n "${BASHMENU_CONFIG_CACHE[$key]}" ]]; then
        echo "${BASHMENU_CONFIG_CACHE[$key]}"
        return 0
    fi
    
    # Check environment variable
    if [[ -n "${!key}" ]]; then
        echo "${!key}"
        return 0
    fi
    
    # Check defaults
    if [[ -n "${BASHMENU_DEFAULTS[$key]}" ]]; then
        echo "${BASHMENU_DEFAULTS[$key]}"
        return 0
    fi
    
    # Return provided default
    echo "$default"
    return 0
}

# set_config() -> int
# Sets a configuration value (runtime only, not persisted)
# Args:
#   $1 - Configuration key
#   $2 - Configuration value
# Returns:
#   0 on success
set_config() {
    local key="$1"
    local value="$2"
    
    declare -g "$key=$value"
    export "$key"
    BASHMENU_CONFIG_CACHE["$key"]="$value"
    
    if declare -f log_debug >/dev/null; then
        log_debug "Set config: $key=$value"
    fi
    
    return 0
}

# is_config_enabled() -> int
# Checks if a boolean configuration is enabled
# Args:
#   $1 - Configuration key
# Returns:
#   0 if enabled, 1 if disabled
is_config_enabled() {
    local key="$1"
    local value
    value=$(get_config "$key" "false")
    
    [[ "$value" == "true" ]]
}

# print_config() -> void
# Prints current configuration (for debugging)
print_config() {
    echo "=== Bashmenu Configuration ==="
    echo ""
    
    local key
    for key in $(compgen -e | grep "^BASHMENU_" | sort); do
        echo "$key=${!key}"
    done
    
    echo ""
    echo "=== Configuration Files Checked ==="
    echo "1. Environment variables (highest priority)"
    echo "2. $HOME/.bashmenu/.bashmenu.env"
    echo "3. /opt/bashmenu/etc/.bashmenu.env"
    echo "4. $(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/.bashmenu.env"
    echo "5. Default values (lowest priority)"
    echo ""
}

# =============================================================================
# Export Functions
# =============================================================================

export -f load_env_file
export -f load_configuration
export -f validate_config
export -f get_config
export -f set_config
export -f is_config_enabled
export -f print_config
