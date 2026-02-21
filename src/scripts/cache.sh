#!/bin/bash

# =============================================================================
# Bashmenu v2.2 - Cache System
# =============================================================================
# Description: High-performance caching system for script scanning and validation
# Version:     1.0.0
# =============================================================================

# =============================================================================
# Global Variables
# =============================================================================

# Cache directory
declare -g CACHE_DIR="${BASHMENU_CACHE_DIR:-$HOME/.bashmenu/cache}"

# Cache files
declare -g CACHE_SCRIPTS="$CACHE_DIR/scripts.cache"
declare -g CACHE_VALIDATION="$CACHE_DIR/validation.cache"
declare -g CACHE_METADATA="$CACHE_DIR/metadata.cache"

# Cache TTL (seconds)
declare -g CACHE_TTL="${BASHMENU_CACHE_TTL:-3600}"

# Cache enabled flag
declare -g CACHE_ENABLED="${BASHMENU_ENABLE_CACHE:-true}"

# Cache statistics
declare -gA CACHE_STATS=(
    [hits]=0
    [misses]=0
    [writes]=0
    [invalidations]=0
)

# =============================================================================
# Cache Initialization
# =============================================================================

# cache_init() -> int
# Initializes the cache system
# Returns: 0 on success, 1 on failure
cache_init() {
    # Check if caching is enabled
    if [[ "$CACHE_ENABLED" != "true" ]]; then
        if declare -f log_debug >/dev/null; then
            log_debug "Cache system disabled"
        fi
        return 0
    fi
    
    # Create cache directory
    if [[ ! -d "$CACHE_DIR" ]]; then
        if ! mkdir -p "$CACHE_DIR" 2>/dev/null; then
            if declare -f log_error >/dev/null; then
                log_error "Failed to create cache directory: $CACHE_DIR"
            fi
            CACHE_ENABLED=false
            return 1
        fi
    fi
    
    # Verify write permissions
    if [[ ! -w "$CACHE_DIR" ]]; then
        if declare -f log_error >/dev/null; then
            log_error "No write permission in cache directory: $CACHE_DIR"
        fi
        CACHE_ENABLED=false
        return 1
    fi
    
    # Initialize cache files if they don't exist
    touch "$CACHE_SCRIPTS" "$CACHE_VALIDATION" "$CACHE_METADATA" 2>/dev/null
    
    if declare -f log_debug >/dev/null; then
        log_debug "Cache system initialized: $CACHE_DIR"
    fi
    
    return 0
}

# =============================================================================
# Cache Operations
# =============================================================================

# cache_get() -> string
# Retrieves a value from cache
# Args:
#   $1 - Cache type (scripts|validation|metadata)
#   $2 - Key
# Returns: Cached value or empty string
cache_get() {
    local cache_type="$1"
    local key="$2"
    
    if [[ "$CACHE_ENABLED" != "true" ]]; then
        return 1
    fi
    
    local cache_file
    case "$cache_type" in
        scripts) cache_file="$CACHE_SCRIPTS" ;;
        validation) cache_file="$CACHE_VALIDATION" ;;
        metadata) cache_file="$CACHE_METADATA" ;;
        *)
            if declare -f log_error >/dev/null; then
                log_error "Invalid cache type: $cache_type"
            fi
            return 1
            ;;
    esac
    
    if [[ ! -f "$cache_file" ]]; then
        CACHE_STATS[misses]=$((${CACHE_STATS[misses]} + 1))
        return 1
    fi
    
    # Look for key in cache file
    local line
    line=$(grep "^${key}|" "$cache_file" 2>/dev/null | head -1)
    
    if [[ -z "$line" ]]; then
        CACHE_STATS[misses]=$((${CACHE_STATS[misses]} + 1))
        return 1
    fi
    
    # Parse cache entry: key|timestamp|value
    local cached_time
    local cached_value
    
    IFS='|' read -r _ cached_time cached_value <<< "$line"
    
    # Check if cache entry is still valid (TTL)
    local current_time=$(date +%s)
    local age=$((current_time - cached_time))
    
    if [[ $age -gt $CACHE_TTL ]]; then
        # Cache expired
        CACHE_STATS[misses]=$((${CACHE_STATS[misses]} + 1))
        return 1
    fi
    
    # Cache hit
    CACHE_STATS[hits]=$((${CACHE_STATS[hits]} + 1))
    echo "$cached_value"
    return 0
}

# cache_set() -> int
# Stores a value in cache
# Args:
#   $1 - Cache type (scripts|validation|metadata)
#   $2 - Key
#   $3 - Value
# Returns: 0 on success, 1 on failure
cache_set() {
    local cache_type="$1"
    local key="$2"
    local value="$3"
    
    if [[ "$CACHE_ENABLED" != "true" ]]; then
        return 0
    fi
    
    local cache_file
    case "$cache_type" in
        scripts) cache_file="$CACHE_SCRIPTS" ;;
        validation) cache_file="$CACHE_VALIDATION" ;;
        metadata) cache_file="$CACHE_METADATA" ;;
        *)
            if declare -f log_error >/dev/null; then
                log_error "Invalid cache type: $cache_type"
            fi
            return 1
            ;;
    esac
    
    # Skip if cache directory doesn't exist
    if [[ ! -d "$CACHE_DIR" ]]; then
        return 0
    fi
    
    local timestamp=$(date +%s)
    
    # Remove old entry if exists
    if [[ -f "$cache_file" ]]; then
        sed -i "/^${key}|/d" "$cache_file" 2>/dev/null
    fi
    
    # Add new entry
    echo "${key}|${timestamp}|${value}" >> "$cache_file"
    
    CACHE_STATS[writes]=$((${CACHE_STATS[writes]} + 1))
    
    if declare -f log_debug >/dev/null; then
        log_debug "Cache set: $cache_type/$key"
    fi
    
    return 0
}

# cache_invalidate() -> int
# Invalidates a specific cache entry
# Args:
#   $1 - Cache type (scripts|validation|metadata)
#   $2 - Key
# Returns: 0 on success
cache_invalidate() {
    local cache_type="$1"
    local key="$2"
    
    if [[ "$CACHE_ENABLED" != "true" ]]; then
        return 0
    fi
    
    local cache_file
    case "$cache_type" in
        scripts) cache_file="$CACHE_SCRIPTS" ;;
        validation) cache_file="$CACHE_VALIDATION" ;;
        metadata) cache_file="$CACHE_METADATA" ;;
        *)
            return 1
            ;;
    esac
    
    if [[ -f "$cache_file" ]]; then
        sed -i "/^${key}|/d" "$cache_file" 2>/dev/null
        CACHE_STATS[invalidations]=$((${CACHE_STATS[invalidations]} + 1))
    fi
    
    if declare -f log_debug >/dev/null; then
        log_debug "Cache invalidated: $cache_type/$key"
    fi
    
    return 0
}

# cache_clear() -> int
# Clears all cache or specific cache type
# Args:
#   $1 - Cache type (optional, clears all if not specified)
# Returns: 0 on success
cache_clear() {
    local cache_type="${1:-all}"
    
    if [[ "$CACHE_ENABLED" != "true" ]]; then
        return 0
    fi
    
    case "$cache_type" in
        scripts)
            > "$CACHE_SCRIPTS"
            ;;
        validation)
            > "$CACHE_VALIDATION"
            ;;
        metadata)
            > "$CACHE_METADATA"
            ;;
        all)
            > "$CACHE_SCRIPTS"
            > "$CACHE_VALIDATION"
            > "$CACHE_METADATA"
            ;;
        *)
            if declare -f log_error >/dev/null; then
                log_error "Invalid cache type: $cache_type"
            fi
            return 1
            ;;
    esac
    
    if declare -f log_info >/dev/null; then
        log_info "Cache cleared: $cache_type"
    fi
    
    return 0
}

# =============================================================================
# Cache Validation with mtime
# =============================================================================

# cache_is_valid() -> int
# Checks if cached data is still valid based on file modification time
# Args:
#   $1 - File path
#   $2 - Cached mtime
# Returns: 0 if valid, 1 if invalid
cache_is_valid() {
    local file_path="$1"
    local cached_mtime="$2"
    
    if [[ ! -f "$file_path" ]]; then
        return 1
    fi
    
    local current_mtime
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        current_mtime=$(stat -f %m "$file_path" 2>/dev/null)
    else
        # Linux
        current_mtime=$(stat -c %Y "$file_path" 2>/dev/null)
    fi
    
    if [[ "$current_mtime" == "$cached_mtime" ]]; then
        return 0
    fi
    
    return 1
}

# get_file_mtime() -> string
# Gets file modification time
# Args:
#   $1 - File path
# Returns: mtime timestamp
get_file_mtime() {
    local file_path="$1"
    
    if [[ ! -f "$file_path" ]]; then
        echo "0"
        return 1
    fi
    
    local mtime
    if [[ "$OSTYPE" == "darwin"* ]]; then
        mtime=$(stat -f %m "$file_path" 2>/dev/null)
    else
        mtime=$(stat -c %Y "$file_path" 2>/dev/null)
    fi
    
    echo "${mtime:-0}"
}

# =============================================================================
# Cache Statistics
# =============================================================================

# cache_stats() -> void
# Displays cache statistics
cache_stats() {
    local total_requests=$((${CACHE_STATS[hits]} + ${CACHE_STATS[misses]}))
    local hit_rate=0
    
    if [[ $total_requests -gt 0 ]]; then
        hit_rate=$((${CACHE_STATS[hits]} * 100 / total_requests))
    fi
    
    echo "=== Cache Statistics ==="
    echo "Hits: ${CACHE_STATS[hits]}"
    echo "Misses: ${CACHE_STATS[misses]}"
    echo "Writes: ${CACHE_STATS[writes]}"
    echo "Invalidations: ${CACHE_STATS[invalidations]}"
    echo "Hit Rate: ${hit_rate}%"
    echo "Cache Dir: $CACHE_DIR"
    echo "TTL: ${CACHE_TTL}s"
    echo "Enabled: $CACHE_ENABLED"
}

# cache_reset_stats() -> void
# Resets cache statistics
cache_reset_stats() {
    CACHE_STATS[hits]=0
    CACHE_STATS[misses]=0
    CACHE_STATS[writes]=0
    CACHE_STATS[invalidations]=0
}

# =============================================================================
# Export Functions
# =============================================================================

export -f cache_init
export -f cache_get
export -f cache_set
export -f cache_invalidate
export -f cache_clear
export -f cache_is_valid
export -f get_file_mtime
export -f cache_stats
export -f cache_reset_stats
