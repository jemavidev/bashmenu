#!/usr/bin/env bash
# Bashmenu v2.2 - Audit System
# JSONL (JSON Lines) audit logging

# Global audit state
declare -g AUDIT_FILE="${BASHMENU_USER_DIR:-$HOME/.bashmenu}/audit.jsonl"
declare -g AUDIT_ENABLED=true
declare -g AUDIT_MAX_SIZE=10485760  # 10MB

#######################################
# Initialize audit system
# Returns:
#   0 on success
#######################################
audit_init() {
    local user_dir="${BASHMENU_USER_DIR:-$HOME/.bashmenu}"
    
    # Create directory
    if [[ ! -d "$user_dir" ]]; then
        mkdir -p "$user_dir" || return 1
    fi
    
    # Create audit file if doesn't exist
    if [[ ! -f "$AUDIT_FILE" ]]; then
        touch "$AUDIT_FILE" || return 1
    fi
    
    # Check if rotation needed
    audit_rotate_if_needed
    
    return 0
}

#######################################
# Log audit event
# Arguments:
#   $1 - Action (execute_script, search, add_favorite, etc.)
#   $2 - Script path (optional)
#   $3 - Result (success|failure)
#   $4 - Exit code (optional)
#   $5 - Duration in ms (optional)
# Returns:
#   0 on success
#######################################
audit_log_event() {
    local action="$1"
    local script="${2:-}"
    local result="${3:-success}"
    local exit_code="${4:-0}"
    local duration="${5:-0}"
    
    if [[ "$AUDIT_ENABLED" != "true" ]]; then
        return 0
    fi
    
    if [[ -z "$action" ]]; then
        echo "Error: Action required" >&2
        return 1
    fi
    
    # Get timestamp
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Get user
    local user="${USER:-unknown}"
    
    # Build JSON line
    local json_line
    json_line=$(printf '{"timestamp":"%s","user":"%s","action":"%s","script":"%s","result":"%s","exit_code":%d,"duration_ms":%d}\n' \
        "$timestamp" "$user" "$action" "$script" "$result" "$exit_code" "$duration")
    
    # Append to file (atomic)
    echo "$json_line" >> "$AUDIT_FILE"
    
    return 0
}

#######################################
# Query audit log
# Arguments:
#   $1 - Filter type (action|user|result|date)
#   $2 - Filter value
#   $3 - Limit (optional, default: 100)
# Outputs:
#   Matching audit entries
#######################################
audit_query() {
    local filter_type="$1"
    local filter_value="$2"
    local limit="${3:-100}"
    
    if [[ ! -f "$AUDIT_FILE" ]]; then
        return 0
    fi
    
    case "$filter_type" in
        action)
            grep "\"action\":\"$filter_value\"" "$AUDIT_FILE" | tail -n "$limit"
            ;;
        user)
            grep "\"user\":\"$filter_value\"" "$AUDIT_FILE" | tail -n "$limit"
            ;;
        result)
            grep "\"result\":\"$filter_value\"" "$AUDIT_FILE" | tail -n "$limit"
            ;;
        date)
            grep "\"timestamp\":\"$filter_value" "$AUDIT_FILE" | tail -n "$limit"
            ;;
        all|*)
            tail -n "$limit" "$AUDIT_FILE"
            ;;
    esac
}

#######################################
# Export audit log
# Arguments:
#   $1 - Export file path
#   $2 - Format (jsonl|json|csv) [default: jsonl]
# Returns:
#   0 on success
#######################################
audit_export() {
    local export_file="$1"
    local format="${2:-jsonl}"
    
    if [[ -z "$export_file" ]]; then
        echo "Error: Export file required" >&2
        return 1
    fi
    
    if [[ ! -f "$AUDIT_FILE" ]]; then
        echo "Error: Audit file not found" >&2
        return 1
    fi
    
    case "$format" in
        jsonl)
            cp "$AUDIT_FILE" "$export_file"
            ;;
        json)
            # Convert JSONL to JSON array
            {
                echo '['
                local first=true
                while IFS= read -r line; do
                    if [[ "$first" == "true" ]]; then
                        first=false
                    else
                        echo ','
                    fi
                    echo -n "  $line"
                done < "$AUDIT_FILE"
                echo ''
                echo ']'
            } > "$export_file"
            ;;
        csv)
            # Convert to CSV
            {
                echo "timestamp,user,action,script,result,exit_code,duration_ms"
                while IFS= read -r line; do
                    # Simple JSON parsing (no jq dependency)
                    local timestamp user action script result exit_code duration
                    timestamp=$(echo "$line" | sed -n 's/.*"timestamp":"\([^"]*\)".*/\1/p')
                    user=$(echo "$line" | sed -n 's/.*"user":"\([^"]*\)".*/\1/p')
                    action=$(echo "$line" | sed -n 's/.*"action":"\([^"]*\)".*/\1/p')
                    script=$(echo "$line" | sed -n 's/.*"script":"\([^"]*\)".*/\1/p')
                    result=$(echo "$line" | sed -n 's/.*"result":"\([^"]*\)".*/\1/p')
                    exit_code=$(echo "$line" | sed -n 's/.*"exit_code":\([0-9]*\).*/\1/p')
                    duration=$(echo "$line" | sed -n 's/.*"duration_ms":\([0-9]*\).*/\1/p')
                    
                    echo "$timestamp,$user,$action,$script,$result,$exit_code,$duration"
                done < "$AUDIT_FILE"
            } > "$export_file"
            ;;
        *)
            echo "Error: Invalid format: $format" >&2
            return 1
            ;;
    esac
    
    echo "Audit log exported to: $export_file"
    return 0
}

#######################################
# Rotate audit log if needed
# Returns:
#   0 on success
#######################################
audit_rotate_if_needed() {
    if [[ ! -f "$AUDIT_FILE" ]]; then
        return 0
    fi
    
    local file_size
    file_size=$(stat -f%z "$AUDIT_FILE" 2>/dev/null || stat -c%s "$AUDIT_FILE" 2>/dev/null || echo 0)
    
    if [[ $file_size -ge $AUDIT_MAX_SIZE ]]; then
        audit_rotate
    fi
    
    return 0
}

#######################################
# Rotate audit log
# Returns:
#   0 on success
#######################################
audit_rotate() {
    if [[ ! -f "$AUDIT_FILE" ]]; then
        return 0
    fi
    
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local rotated_file="${AUDIT_FILE}.${timestamp}"
    
    # Move current file
    mv "$AUDIT_FILE" "$rotated_file"
    
    # Create new file
    touch "$AUDIT_FILE"
    
    # Compress old file
    if command -v gzip >/dev/null 2>&1; then
        gzip "$rotated_file"
        echo "Audit log rotated and compressed: ${rotated_file}.gz"
    else
        echo "Audit log rotated: $rotated_file"
    fi
    
    # Keep only last 5 rotated files
    local user_dir="${BASHMENU_USER_DIR:-$HOME/.bashmenu}"
    find "$user_dir" -name "audit.jsonl.*" -type f | sort -r | tail -n +6 | xargs rm -f 2>/dev/null || true
    
    return 0
}

#######################################
# Get audit statistics
# Outputs:
#   JSON with statistics
#######################################
audit_stats() {
    if [[ ! -f "$AUDIT_FILE" ]]; then
        echo '{"total_events":0,"file_size":0}'
        return 0
    fi
    
    local total_events
    total_events=$(wc -l < "$AUDIT_FILE" | tr -d ' ')
    
    local file_size
    file_size=$(stat -f%z "$AUDIT_FILE" 2>/dev/null || stat -c%s "$AUDIT_FILE" 2>/dev/null || echo 0)
    
    local success_count failure_count
    success_count=$(grep -c '"result":"success"' "$AUDIT_FILE" 2>/dev/null || echo 0)
    failure_count=$(grep -c '"result":"failure"' "$AUDIT_FILE" 2>/dev/null || echo 0)
    
    cat << EOF
{
  "total_events": $total_events,
  "file_size": $file_size,
  "success_count": $success_count,
  "failure_count": $failure_count,
  "audit_file": "$AUDIT_FILE"
}
EOF
}

#######################################
# Clear audit log
# Returns:
#   0 on success
#######################################
audit_clear() {
    if [[ -f "$AUDIT_FILE" ]]; then
        > "$AUDIT_FILE"
        echo "Audit log cleared"
    fi
    return 0
}

#######################################
# Enable audit logging
#######################################
audit_enable() {
    AUDIT_ENABLED=true
    echo "Audit logging enabled"
}

#######################################
# Disable audit logging
#######################################
audit_disable() {
    AUDIT_ENABLED=false
    echo "Audit logging disabled"
}

# Export functions
export -f audit_init
export -f audit_log_event
export -f audit_query
export -f audit_export
export -f audit_rotate_if_needed
export -f audit_rotate
export -f audit_stats
export -f audit_clear
export -f audit_enable
export -f audit_disable
