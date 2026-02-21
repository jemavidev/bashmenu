#!/usr/bin/env bash
# Bashmenu v2.2 - Search System
# Real-time incremental search with keyboard navigation

# Global search state
declare -g SEARCH_QUERY=""
declare -g SEARCH_RESULTS=()
declare -g SEARCH_SELECTED=0
declare -g SEARCH_CACHE_ENABLED=true

#######################################
# Initialize search system
# Globals:
#   BASHMENU_ENABLE_CACHE
# Arguments:
#   None
# Returns:
#   0 on success
#######################################
search_init() {
    SEARCH_QUERY=""
    SEARCH_RESULTS=()
    SEARCH_SELECTED=0
    
    # Check if cache is enabled
    if [[ "${BASHMENU_ENABLE_CACHE:-true}" == "false" ]]; then
        SEARCH_CACHE_ENABLED=false
    fi
    
    return 0
}

#######################################
# Search scripts by name
# Arguments:
#   $1 - Query string
#   $2 - Scripts directory
# Outputs:
#   Matching script paths (one per line)
#######################################
search_by_name() {
    local query="$1"
    local scripts_dir="$2"
    
    if [[ -z "$query" ]]; then
        return 0
    fi
    
    # Case-insensitive search
    find "$scripts_dir" -type f -name "*.sh" 2>/dev/null | \
        grep -i "$query"
}

#######################################
# Search scripts by description
# Arguments:
#   $1 - Query string
#   $2 - Scripts directory
# Outputs:
#   Matching script paths (one per line)
#######################################
search_by_description() {
    local query="$1"
    local scripts_dir="$2"
    local script
    
    if [[ -z "$query" ]]; then
        return 0
    fi
    
    # Search in script comments/descriptions
    while IFS= read -r script; do
        if head -n 20 "$script" 2>/dev/null | grep -qi "$query"; then
            echo "$script"
        fi
    done < <(find "$scripts_dir" -type f -name "*.sh" 2>/dev/null)
}

#######################################
# Search scripts by tags
# Arguments:
#   $1 - Query string (tag)
#   $2 - Scripts directory
# Outputs:
#   Matching script paths (one per line)
#######################################
search_by_tags() {
    local query="$1"
    local scripts_dir="$2"
    local script
    
    if [[ -z "$query" ]]; then
        return 0
    fi
    
    # Search for tags in script headers
    while IFS= read -r script; do
        if head -n 30 "$script" 2>/dev/null | grep -qi "tag.*:.*$query"; then
            echo "$script"
        fi
    done < <(find "$scripts_dir" -type f -name "*.sh" 2>/dev/null)
}

#######################################
# Perform incremental search
# Arguments:
#   $1 - Query string
#   $2 - Scripts directory
#   $3 - Search mode (name|description|tags|all)
# Outputs:
#   Array of matching scripts
# Returns:
#   Number of results found
#######################################
search_incremental() {
    local query="$1"
    local scripts_dir="$2"
    local mode="${3:-all}"
    local -a results=()
    local start_time end_time duration
    
    start_time=$(date +%s%N 2>/dev/null || date +%s)
    
    if [[ -z "$query" ]]; then
        SEARCH_RESULTS=()
        return 0
    fi
    
    case "$mode" in
        name)
            mapfile -t results < <(search_by_name "$query" "$scripts_dir")
            ;;
        description)
            mapfile -t results < <(search_by_description "$query" "$scripts_dir")
            ;;
        tags)
            mapfile -t results < <(search_by_tags "$query" "$scripts_dir")
            ;;
        all|*)
            # Combine all search methods and remove duplicates
            mapfile -t results < <(
                {
                    search_by_name "$query" "$scripts_dir"
                    search_by_description "$query" "$scripts_dir"
                    search_by_tags "$query" "$scripts_dir"
                } | sort -u
            )
            ;;
    esac
    
    SEARCH_RESULTS=("${results[@]}")
    
    end_time=$(date +%s%N 2>/dev/null || date +%s)
    
    # Calculate duration (in milliseconds if nanoseconds available)
    if [[ "$start_time" =~ [0-9]{10,} ]]; then
        duration=$(( (end_time - start_time) / 1000000 ))
    else
        duration=$(( (end_time - start_time) * 1000 ))
    fi
    
    # Log performance warning if > 200ms
    if [[ $duration -gt 200 ]]; then
        echo "Warning: Search took ${duration}ms (target: <200ms)" >&2
    fi
    
    return "${#results[@]}"
}

#######################################
# Highlight search query in text
# Arguments:
#   $1 - Text to highlight
#   $2 - Query to highlight
# Outputs:
#   Text with ANSI color codes
#######################################
highlight_results() {
    local text="$1"
    local query="$2"
    
    if [[ -z "$query" ]]; then
        echo "$text"
        return 0
    fi
    
    # Use ANSI codes for highlighting (yellow background)
    echo "$text" | sed "s/$query/\x1b[43m&\x1b[0m/gi"
}

#######################################
# Display search UI
# Arguments:
#   $1 - Current query
#   $2 - Results array (passed by name)
#   $3 - Selected index
# Outputs:
#   Formatted search UI
#######################################
display_search_ui() {
    local query="$1"
    local -n results_ref="$2"
    local selected="${3:-0}"
    local max_display=10
    local i=0
    
    # Clear screen
    clear
    
    # Header
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🔍 SEARCH MODE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Search input
    echo -n "  Query: "
    if [[ -n "$query" ]]; then
        echo "$query"
    else
        echo "(type to search...)"
    fi
    echo ""
    
    # Results count
    echo "  Found: ${#results_ref[@]} results"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Display results
    if [[ ${#results_ref[@]} -eq 0 ]]; then
        echo "  No results found."
    else
        for ((i=0; i<${#results_ref[@]} && i<max_display; i++)); do
            local script="${results_ref[$i]}"
            local basename="${script##*/}"
            
            if [[ $i -eq $selected ]]; then
                echo -e "  ▶ \x1b[1;32m$basename\x1b[0m"
                echo "    $script"
            else
                echo "    $basename"
            fi
        done
        
        if [[ ${#results_ref[@]} -gt $max_display ]]; then
            echo ""
            echo "  ... and $((${#results_ref[@]} - max_display)) more"
        fi
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  [↑/↓] Navigate  [Enter] Select  [Esc/q] Exit"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

#######################################
# Interactive search mode
# Arguments:
#   $1 - Scripts directory
# Outputs:
#   Selected script path (if any)
# Returns:
#   0 if script selected, 1 if cancelled
#######################################
search_interactive() {
    local scripts_dir="$1"
    local query=""
    local selected=0
    local key
    
    search_init
    
    # Initial display
    display_search_ui "$query" SEARCH_RESULTS "$selected"
    
    # Read input character by character
    while true; do
        # Read single character
        read -rsn1 key
        
        case "$key" in
            $'\x1b')  # Escape sequence
                read -rsn2 -t 0.1 key
                case "$key" in
                    '[A')  # Up arrow
                        if [[ $selected -gt 0 ]]; then
                            ((selected--))
                            display_search_ui "$query" SEARCH_RESULTS "$selected"
                        fi
                        ;;
                    '[B')  # Down arrow
                        if [[ $selected -lt $((${#SEARCH_RESULTS[@]} - 1)) ]]; then
                            ((selected++))
                            display_search_ui "$query" SEARCH_RESULTS "$selected"
                        fi
                        ;;
                esac
                ;;
            '')  # Enter
                if [[ ${#SEARCH_RESULTS[@]} -gt 0 ]]; then
                    echo "${SEARCH_RESULTS[$selected]}"
                    return 0
                fi
                ;;
            'q'|'Q')  # Quit
                return 1
                ;;
            $'\x7f')  # Backspace
                if [[ -n "$query" ]]; then
                    query="${query%?}"
                    search_incremental "$query" "$scripts_dir" "all"
                    selected=0
                    display_search_ui "$query" SEARCH_RESULTS "$selected"
                fi
                ;;
            *)  # Regular character
                if [[ -n "$key" ]]; then
                    query="${query}${key}"
                    search_incremental "$query" "$scripts_dir" "all"
                    selected=0
                    display_search_ui "$query" SEARCH_RESULTS "$selected"
                fi
                ;;
        esac
    done
}

#######################################
# Get search statistics
# Outputs:
#   JSON with search stats
#######################################
search_stats() {
    cat << EOF
{
  "current_query": "$SEARCH_QUERY",
  "results_count": ${#SEARCH_RESULTS[@]},
  "selected_index": $SEARCH_SELECTED,
  "cache_enabled": $SEARCH_CACHE_ENABLED
}
EOF
}

# Export functions
export -f search_init
export -f search_by_name
export -f search_by_description
export -f search_by_tags
export -f search_incremental
export -f highlight_results
export -f display_search_ui
export -f search_interactive
export -f search_stats
