#!/bin/bash

# =============================================================================
# Caching System for Bashmenu Plugin Scanning
# =============================================================================
# Description: Intelligent caching system to improve plugin scanning performance
# Version:     1.0
# =============================================================================

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Cache Configuration
# =============================================================================

# Cache directory and files
readonly CACHE_DIR="${HOME}/.cache/bashmenu"
readonly PLUGIN_CACHE_FILE="${CACHE_DIR}/plugin_cache.dat"
readonly PLUGIN_METADATA_FILE="${CACHE_DIR}/plugin_metadata.json"
readonly CACHE_LOCK_FILE="${CACHE_DIR}/.cache_lock"

# Cache settings
readonly CACHE_TTL=3600  # 1 hour in seconds
readonly CACHE_VERSION="1.0"
readonly MAX_CACHE_SIZE=1048576  # 1MB

# Cache statistics
CACHE_HITS=0
CACHE_MISSES=0
CACHE_UPDATES=0

# =============================================================================
# Cache Data Structures
# =============================================================================

declare -A PLUGIN_CACHE
declare -A PLUGIN_METADATA

# =============================================================================
# Cache Initialization
# =============================================================================

# Initialize cache system
initialize_cache() {
    # Create cache directory if it doesn't exist
    mkdir -p "$CACHE_DIR"
    
    # Create cache lock file
    touch "$CACHE_LOCK_FILE"
    
    # Load existing cache
    load_cache
    
    # Clean up old cache files
    cleanup_old_cache
    
    if declare -f log_debug >/dev/null; then
        log_debug "Cache system initialized"
    fi
}

# Clean up old cache files
cleanup_old_cache() {
    find "$CACHE_DIR" -name "*.tmp" -type f -mtime +1 -delete 2>/dev/null || true
    find "$CACHE_DIR" -name "*.bak" -type f -mtime +7 -delete 2>/dev/null || true
}

# =============================================================================
# Cache Loading and Saving
# =============================================================================

# Load cache from disk
load_cache() {
    if [[ -f "$PLUGIN_CACHE_FILE" ]]; then
        # Check if cache is valid
        if is_cache_valid; then
            # Read cache file
            while IFS='=' read -r key value; do
                if [[ -n "$key" && -n "$value" ]]; then
                    PLUGIN_CACHE["$key"]="$value"
                fi
            done < "$PLUGIN_CACHE_FILE"
            
            CACHE_HITS=$((CACHE_HITS + 1))
            if declare -f log_debug >/dev/null; then
                log_debug "Cache loaded: ${#PLUGIN_CACHE[@]} entries"
            fi
        else
            CACHE_MISSES=$((CACHE_MISSES + 1))
            if declare -f log_debug >/dev/null; then
                log_debug "Cache invalid or expired"
            fi
        fi
    else
        CACHE_MISSES=$((CACHE_MISSES + 1))
        if declare -f log_debug >/dev/null; then
            log_debug "Cache file not found"
        fi
    fi
    
    # Load metadata
    if [[ -f "$PLUGIN_METADATA_FILE" ]]; then
        # Simple JSON parsing (basic implementation)
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*\"([^\"]+)\"[[:space:]]*:[[:space:]]*\"([^\"]+)\"[[:space:]]*$ ]]; then
                PLUGIN_METADATA["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
            fi
        done < "$PLUGIN_METADATA_FILE"
    fi
}

# Save cache to disk
save_cache() {
    # Acquire lock
    acquire_cache_lock || return 1
    
    # Create temporary file
    local temp_cache_file="${PLUGIN_CACHE_FILE}.tmp.$$"
    
    # Write cache to temporary file
    {
        echo "# Bashmenu Plugin Cache"
        echo "# Generated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "# Version: $CACHE_VERSION"
        echo "# Entries: ${#PLUGIN_CACHE[@]}"
        echo ""
        
        for key in "${!PLUGIN_CACHE[@]}"; do
            echo "${key}=${PLUGIN_CACHE[$key]}"
        done
    } > "$temp_cache_file"
    
    # Move temporary file to final location
    mv "$temp_cache_file" "$PLUGIN_CACHE_FILE"
    
    # Save metadata
    save_metadata
    
    # Release lock
    release_cache_lock
    
    CACHE_UPDATES=$((CACHE_UPDATES + 1))
    
    if declare -f log_debug >/dev/null; then
        log_debug "Cache saved: ${#PLUGIN_CACHE[@]} entries"
    fi
}

# Save metadata
save_metadata() {
    {
        echo "{"
        echo "  \"version\": \"$CACHE_VERSION\","
        echo "  \"generated\": \"$(date -Iseconds)\","
        echo "  \"entries\": \"${#PLUGIN_CACHE[@]}\","
        echo "  \"hits\": \"$CACHE_HITS\","
        echo "  \"misses\": \"$CACHE_MISSES\","
        echo "  \"updates\": \"$CACHE_UPDATES\""
        echo "}"
    } > "$PLUGIN_METADATA_FILE"
}

# =============================================================================
# Cache Validation
# =============================================================================

# Check if cache is valid
is_cache_valid() {
    # Check if cache file exists
    if [[ ! -f "$PLUGIN_CACHE_FILE" ]]; then
        return 1
    fi
    
    # Check cache file age
    local cache_age
    cache_age=$(($(date +%s) - $(stat -c %Y "$PLUGIN_CACHE_FILE" 2>/dev/null || echo 0)))
    
    if [[ $cache_age -gt $CACHE_TTL ]]; then
        if declare -f log_debug >/dev/null; then
            log_debug "Cache expired: ${cache_age}s old"
        fi
        return 1
    fi
    
    # Check cache file size
    local cache_size
    cache_size=$(stat -c %s "$PLUGIN_CACHE_FILE" 2>/dev/null || echo 0)
    
    if [[ $cache_size -gt $MAX_CACHE_SIZE ]]; then
        if declare -f log_debug >/dev/null; then
            log_debug "Cache too large: ${cache_size} bytes"
        fi
        return 1
    fi
    
    # Check cache version
    if grep -q "# Version: $CACHE_VERSION" "$PLUGIN_CACHE_FILE" 2>/dev/null; then
        return 0
    else
        if declare -f log_debug >/dev/null; then
            log_debug "Cache version mismatch"
        fi
        return 1
    fi
}

# =============================================================================
# Cache Locking
# =============================================================================

# Acquire cache lock
acquire_cache_lock() {
    local lock_timeout=30
    local lock_count=0
    
    while [[ $lock_count -lt $lock_timeout ]]; do
        if (set -C; echo $$ > "$CACHE_LOCK_FILE") 2>/dev/null; then
            return 0
        fi
        
        # Check if lock is stale
        local lock_pid
        lock_pid=$(cat "$CACHE_LOCK_FILE" 2>/dev/null || echo "")
        if [[ -n "$lock_pid" ]] && ! kill -0 "$lock_pid" 2>/dev/null; then
            # Lock is stale, remove it
            rm -f "$CACHE_LOCK_FILE"
            continue
        fi
        
        sleep 1
        lock_count=$((lock_count + 1))
    done
    
    if declare -f log_error >/dev/null; then
        log_error "Failed to acquire cache lock"
    fi
    return 1
}

# Release cache lock
release_cache_lock() {
    rm -f "$CACHE_LOCK_FILE" 2>/dev/null || true
}

# =============================================================================
# Cache Operations
# =============================================================================

# Get cached plugin information
get_cached_plugin_info() {
    local plugin_path="$1"
    local cache_key="plugin:$(realpath "$plugin_path" 2>/dev/null || echo "$plugin_path")"
    
    if [[ -n "${PLUGIN_CACHE[$cache_key]:-}" ]]; then
        echo "${PLUGIN_CACHE[$cache_key]}"
        CACHE_HITS=$((CACHE_HITS + 1))
        return 0
    else
        CACHE_MISSES=$((CACHE_MISSES + 1))
        return 1
    fi
}

# Set cached plugin information
set_cached_plugin_info() {
    local plugin_path="$1"
    local plugin_info="$2"
    local cache_key="plugin:$(realpath "$plugin_path" 2>/dev/null || echo "$plugin_path")"
    
    PLUGIN_CACHE["$cache_key"]="$plugin_info"
}

# Get cached directory scan results
get_cached_directory_scan() {
    local directory="$1"
    local scan_depth="${2:-3}"
    local cache_key="scan:$(realpath "$directory" 2>/dev/null || echo "$directory"):$scan_depth"
    
    if [[ -n "${PLUGIN_CACHE[$cache_key]:-}" ]]; then
        echo "${PLUGIN_CACHE[$cache_key]}"
        CACHE_HITS=$((CACHE_HITS + 1))
        return 0
    else
        CACHE_MISSES=$((CACHE_MISSES + 1))
        return 1
    fi
}

# Set cached directory scan results
set_cached_directory_scan() {
    local directory="$1"
    local scan_depth="$2"
    local scan_results="$3"
    local cache_key="scan:$(realpath "$directory" 2>/dev/null || echo "$directory"):$scan_depth"
    
    PLUGIN_CACHE["$cache_key"]="$scan_results"
}

# Invalidate cache for specific plugin
invalidate_plugin_cache() {
    local plugin_path="$1"
    local cache_key="plugin:$(realpath "$plugin_path" 2>/dev/null || echo "$plugin_path")"
    
    unset PLUGIN_CACHE["$cache_key"]
    
    if declare -f log_debug >/dev/null; then
        log_debug "Invalidated cache for: $plugin_path"
    fi
}

# Invalidate cache for directory
invalidate_directory_cache() {
    local directory="$1"
    local directory_realpath
    directory_realpath=$(realpath "$directory" 2>/dev/null || echo "$directory")
    
    # Remove all cache entries for this directory
    for key in "${!PLUGIN_CACHE[@]}"; do
        if [[ "$key" =~ ^scan:$directory_realpath: ]] || [[ "$key" =~ ^plugin:$directory_realpath ]]; then
            unset PLUGIN_CACHE["$key"]
        fi
    done
    
    if declare -f log_debug >/dev/null; then
        log_debug "Invalidated cache for directory: $directory"
    fi
}

# Clear entire cache
clear_cache() {
    PLUGIN_CACHE=()
    PLUGIN_METADATA=()
    
    rm -f "$PLUGIN_CACHE_FILE" "$PLUGIN_METADATA_FILE"
    
    CACHE_HITS=0
    CACHE_MISSES=0
    CACHE_UPDATES=0
    
    if declare -f log_info >/dev/null; then
        log_info "Cache cleared"
    fi
}

# =============================================================================
# Cache Integration with Plugin Scanner
# =============================================================================

# Enhanced plugin scanner with caching
cached_scan_plugin_directories() {
    local plugin_dirs="$1"
    local scan_depth="${2:-3}"
    local extensions="${3:-.sh}"
    
    if declare -f log_debug >/dev/null; then
        log_debug "Starting cached plugin scan: dirs=$plugin_dirs, depth=$scan_depth"
    fi
    
    # Check if we have cached results
    local cache_key="master_scan:${plugin_dirs}:${scan_depth}:${extensions}"
    local cached_results
    if cached_results=$(get_cached_directory_scan "$cache_key"); then
        echo "$cached_results"
        return 0
    fi
    
    # Perform actual scan
    local scan_results=""
    local IFS=':'
    
    for dir in $plugin_dirs; do
        if [[ -d "$dir" ]]; then
            # Check directory-specific cache
            local dir_cache_result
            if dir_cache_result=$(get_cached_directory_scan "$dir" "$scan_depth"); then
                scan_results="${scan_results}${dir_cache_result}"
            else
                # Scan directory and cache results
                local dir_result
                dir_result=$(scan_directory_cached "$dir" "$scan_depth" "$extensions")
                scan_results="${scan_results}${dir_result}"
                set_cached_directory_scan "$dir" "$scan_depth" "$dir_result"
            fi
        fi
    done
    
    # Cache master results
    set_cached_directory_scan "$cache_key" "" "$scan_results"
    
    # Save cache to disk
    save_cache
    
    echo "$scan_results"
}

# Scan directory with caching for individual files
scan_directory_cached() {
    local directory="$1"
    local scan_depth="$2"
    local extensions="$3"
    local results=""
    
    # Build find command
    local find_cmd="find \"$directory\" -maxdepth $scan_depth -type f"
    
    # Add extensions
    local IFS=' '
    local ext_array=($extensions)
    local ext_conditions=()
    for ext in "${ext_array[@]}"; do
        ext_conditions+=("-name" "*$ext")
    done
    
    # Use -o for OR condition between extensions
    for ((i=0; i<${#ext_conditions[@]}; i+=2)); do
        if [[ $i -gt 0 ]]; then
            find_cmd="$find_cmd -o"
        fi
        find_cmd="$find_cmd ${ext_conditions[i]} ${ext_conditions[i+1]}"
    done
    
    # Execute find command and process results
    while IFS= read -r -d '' script_file; do
        if [[ -r "$script_file" && -x "$script_file" ]]; then
            # Check individual file cache
            local cached_info
            if cached_info=$(get_cached_plugin_info "$script_file"); then
                results="${results}${cached_info}"
            else
                # Generate plugin info and cache it
                local plugin_info
                plugin_info=$(generate_plugin_info "$script_file")
                results="${results}${plugin_info}"
                set_cached_plugin_info "$script_file" "$plugin_info"
            fi
        fi
    done < <(eval "$find_cmd -print0" 2>/dev/null)
    
    echo "$results"
}

# Generate plugin information for caching
generate_plugin_info() {
    local script_file="$1"
    local script_name
    local script_desc
    local script_level="1"
    
    script_name=$(basename "$script_file" .sh)
    script_desc="Auto-detected script"
    
    # Try to extract description from script
    if [[ -r "$script_file" ]]; then
        script_desc=$(head -10 "$script_file" | grep -i "description\|desc" | head -1 | cut -d':' -f2- | sed 's/^ *//' | sed 's/^["'\'']//' | sed 's/["'\'']$//' || echo "Auto-detected script")
    fi
    
    # Generate cache entry
    echo "${script_name}|${script_file}|${script_desc}|${script_level}|"
}

# =============================================================================
# Cache Statistics and Management
# =============================================================================

# Get cache statistics
get_cache_statistics() {
    echo "Cache Statistics:"
    echo "  Cache Directory: $CACHE_DIR"
    echo "  Cache File: $PLUGIN_CACHE_FILE"
    echo "  Cache Entries: ${#PLUGIN_CACHE[@]}"
    echo "  Cache Hits: $CACHE_HITS"
    echo "  Cache Misses: $CACHE_MISSES"
    echo "  Cache Updates: $CACHE_UPDATES"
    
    if [[ $((CACHE_HITS + CACHE_MISSES)) -gt 0 ]]; then
        local hit_rate
        hit_rate=$(echo "scale=2; $CACHE_HITS * 100 / ($CACHE_HITS + $CACHE_MISSES)" | bc -l 2>/dev/null || echo "0")
        echo "  Hit Rate: ${hit_rate}%"
    fi
    
    if [[ -f "$PLUGIN_CACHE_FILE" ]]; then
        local cache_size
        cache_size=$(stat -c %s "$PLUGIN_CACHE_FILE" 2>/dev/null || echo 0)
        echo "  Cache Size: ${cache_size} bytes"
    fi
}

# Optimize cache
optimize_cache() {
    # Remove expired entries
    local current_time
    current_time=$(date +%s)
    
    for key in "${!PLUGIN_CACHE[@]}"; do
        if [[ "$key" =~ ^expires:(.+)$ ]]; then
            local expiry_time="${PLUGIN_CACHE[$key]}"
            if [[ $current_time -gt $expiry_time ]]; then
                unset PLUGIN_CACHE["$key"]
            fi
        fi
    done
    
    # Save optimized cache
    save_cache
    
    if declare -f log_info >/dev/null; then
        log_info "Cache optimized"
    fi
}

# Export all functions
export -f initialize_cache
export -f cleanup_old_cache
export -f load_cache
export -f save_cache
export -f save_metadata
export -f is_cache_valid
export -f acquire_cache_lock
export -f release_cache_lock
export -f get_cached_plugin_info
export -f set_cached_plugin_info
export -f get_cached_directory_scan
export -f set_cached_directory_scan
export -f invalidate_plugin_cache
export -f invalidate_directory_cache
export -f clear_cache
export -f cached_scan_plugin_directories
export -f scan_directory_cached
export -f generate_plugin_info
export -f get_cache_statistics
export -f optimize_cache

# Export constants
export CACHE_DIR PLUGIN_CACHE_FILE PLUGIN_METADATA_FILE CACHE_LOCK_FILE
export CACHE_TTL CACHE_VERSION MAX_CACHE_SIZE

# Export variables
export PLUGIN_CACHE PLUGIN_METADATA
export CACHE_HITS CACHE_MISSES CACHE_UPDATES