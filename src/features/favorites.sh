#!/usr/bin/env bash
# Bashmenu v2.2 - Favorites System
# Persistent favorites with JSON storage

# Global favorites state
declare -g FAVORITES_FILE="${BASHMENU_USER_DIR:-$HOME/.bashmenu}/favorites.json"
declare -A FAVORITES_MAP

#######################################
# Initialize favorites system
# Globals:
#   FAVORITES_FILE
#   FAVORITES_MAP
# Returns:
#   0 on success
#######################################
favorites_init() {
    local user_dir="${BASHMENU_USER_DIR:-$HOME/.bashmenu}"
    
    # Create user directory if needed
    if [[ ! -d "$user_dir" ]]; then
        mkdir -p "$user_dir" || return 1
    fi
    
    # Create empty favorites file if doesn't exist
    if [[ ! -f "$FAVORITES_FILE" ]]; then
        cat > "$FAVORITES_FILE" << 'EOF'
{
  "version": "1.0",
  "favorites": []
}
EOF
    fi
    
    # Load favorites into memory
    favorites_load
    
    return 0
}

#######################################
# Load favorites from JSON file
# Globals:
#   FAVORITES_FILE
#   FAVORITES_MAP
# Returns:
#   0 on success, 1 on error
#######################################
favorites_load() {
    local json content
    
    if [[ ! -f "$FAVORITES_FILE" ]]; then
        return 1
    fi
    
    # Clear existing map
    FAVORITES_MAP=()
    
    # Read JSON (simple parsing without jq dependency)
    while IFS= read -r line; do
        if [[ "$line" =~ \"script\":[[:space:]]*\"([^\"]+)\" ]]; then
            local script="${BASH_REMATCH[1]}"
            FAVORITES_MAP["$script"]=1
        fi
    done < "$FAVORITES_FILE"
    
    return 0
}

#######################################
# Save favorites to JSON file
# Globals:
#   FAVORITES_FILE
#   FAVORITES_MAP
# Returns:
#   0 on success, 1 on error
#######################################
favorites_save() {
    local temp_file="${FAVORITES_FILE}.tmp"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%d %H:%M:%S")
    
    # Build JSON
    {
        echo '{'
        echo '  "version": "1.0",'
        echo '  "favorites": ['
        
        local first=true
        for script in "${!FAVORITES_MAP[@]}"; do
            if [[ "$first" == true ]]; then
                first=false
            else
                echo ','
            fi
            
            local name="${script##*/}"
            name="${name%.sh}"
            
            echo -n '    {'
            echo -n "\"script\": \"$script\", "
            echo -n "\"name\": \"$name\", "
            echo -n "\"added\": \"$timestamp\""
            echo -n '}'
        done
        
        echo ''
        echo '  ]'
        echo '}'
    } > "$temp_file"
    
    # Atomic replace
    mv "$temp_file" "$FAVORITES_FILE" || return 1
    
    return 0
}

#######################################
# Add script to favorites
# Arguments:
#   $1 - Script path
# Returns:
#   0 on success, 1 if already exists
#######################################
favorites_add() {
    local script="$1"
    
    if [[ -z "$script" ]]; then
        echo "Error: Script path required" >&2
        return 1
    fi
    
    if [[ ! -f "$script" ]]; then
        echo "Error: Script not found: $script" >&2
        return 1
    fi
    
    # Check if already in favorites
    if [[ -n "${FAVORITES_MAP[$script]}" ]]; then
        echo "Already in favorites: $script" >&2
        return 1
    fi
    
    # Add to map
    FAVORITES_MAP["$script"]=1
    
    # Save to file
    favorites_save
    
    echo "Added to favorites: $script"
    return 0
}

#######################################
# Remove script from favorites
# Arguments:
#   $1 - Script path
# Returns:
#   0 on success, 1 if not found
#######################################
favorites_remove() {
    local script="$1"
    
    if [[ -z "$script" ]]; then
        echo "Error: Script path required" >&2
        return 1
    fi
    
    # Check if in favorites
    if [[ -z "${FAVORITES_MAP[$script]}" ]]; then
        echo "Not in favorites: $script" >&2
        return 1
    fi
    
    # Remove from map
    unset "FAVORITES_MAP[$script]"
    
    # Save to file
    favorites_save
    
    echo "Removed from favorites: $script"
    return 0
}

#######################################
# Toggle favorite status
# Arguments:
#   $1 - Script path
# Returns:
#   0 on success
#######################################
favorites_toggle() {
    local script="$1"
    
    if [[ -n "${FAVORITES_MAP[$script]}" ]]; then
        favorites_remove "$script"
    else
        favorites_add "$script"
    fi
}

#######################################
# Check if script is in favorites
# Arguments:
#   $1 - Script path
# Returns:
#   0 if favorite, 1 if not
#######################################
favorites_is_favorite() {
    local script="$1"
    
    if [[ -n "${FAVORITES_MAP[$script]}" ]]; then
        return 0
    else
        return 1
    fi
}

#######################################
# List all favorites
# Outputs:
#   List of favorite scripts (one per line)
#######################################
favorites_list() {
    for script in "${!FAVORITES_MAP[@]}"; do
        echo "$script"
    done | sort
}

#######################################
# Get favorite indicator for display
# Arguments:
#   $1 - Script path
# Outputs:
#   Star emoji if favorite, empty otherwise
#######################################
favorites_indicator() {
    local script="$1"
    
    if favorites_is_favorite "$script"; then
        echo "⭐"
    else
        echo "  "
    fi
}

#######################################
# Export favorites to file
# Arguments:
#   $1 - Export file path
# Returns:
#   0 on success
#######################################
favorites_export() {
    local export_file="$1"
    
    if [[ -z "$export_file" ]]; then
        echo "Error: Export file path required" >&2
        return 1
    fi
    
    cp "$FAVORITES_FILE" "$export_file" || return 1
    
    echo "Favorites exported to: $export_file"
    return 0
}

#######################################
# Import favorites from file
# Arguments:
#   $1 - Import file path
#   $2 - Merge mode (merge|replace) [default: merge]
# Returns:
#   0 on success
#######################################
favorites_import() {
    local import_file="$1"
    local mode="${2:-merge}"
    
    if [[ -z "$import_file" ]]; then
        echo "Error: Import file path required" >&2
        return 1
    fi
    
    if [[ ! -f "$import_file" ]]; then
        echo "Error: Import file not found: $import_file" >&2
        return 1
    fi
    
    if [[ "$mode" == "replace" ]]; then
        # Replace existing favorites
        cp "$import_file" "$FAVORITES_FILE" || return 1
    else
        # Merge with existing
        local temp_map
        declare -A temp_map
        
        # Load existing
        for script in "${!FAVORITES_MAP[@]}"; do
            temp_map["$script"]=1
        done
        
        # Load from import file
        while IFS= read -r line; do
            if [[ "$line" =~ \"script\":[[:space:]]*\"([^\"]+)\" ]]; then
                temp_map["${BASH_REMATCH[1]}"]=1
            fi
        done < "$import_file"
        
        # Update map
        FAVORITES_MAP=()
        for script in "${!temp_map[@]}"; do
            FAVORITES_MAP["$script"]=1
        done
        
        # Save merged
        favorites_save
    fi
    
    # Reload
    favorites_load
    
    echo "Favorites imported from: $import_file (mode: $mode)"
    return 0
}

#######################################
# Get favorites count
# Outputs:
#   Number of favorites
#######################################
favorites_count() {
    echo "${#FAVORITES_MAP[@]}"
}

#######################################
# Clear all favorites
# Returns:
#   0 on success
#######################################
favorites_clear() {
    FAVORITES_MAP=()
    favorites_save
    echo "All favorites cleared"
    return 0
}

# Export functions
export -f favorites_init
export -f favorites_load
export -f favorites_save
export -f favorites_add
export -f favorites_remove
export -f favorites_toggle
export -f favorites_is_favorite
export -f favorites_list
export -f favorites_indicator
export -f favorites_export
export -f favorites_import
export -f favorites_count
export -f favorites_clear
