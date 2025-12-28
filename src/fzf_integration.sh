#!/bin/bash

# =============================================================================
# fzf Integration for Bashmenu
# =============================================================================
# Descripción: Integración de fzf para búsqueda interactiva de scripts
# Versión:     2.1
# Autor:       JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Global Variables
# =============================================================================

FZF_AVAILABLE=false
FZF_PREVIEW="${FZF_PREVIEW:-true}"
FZF_HEIGHT="${FZF_HEIGHT:-40}"

# =============================================================================
# Detection Functions
# =============================================================================

# detect_fzf() - Detect if fzf is available
# Returns: 0 if found, 1 if not found
detect_fzf() {
    if command -v fzf &>/dev/null; then
        FZF_AVAILABLE=true
        if declare -f log_info &>/dev/null; then
            log_info "fzf detected and available for interactive search"
        fi
        return 0
    else
        FZF_AVAILABLE=false
        if declare -f log_debug &>/dev/null; then
            log_debug "fzf not found, search features disabled"
        fi
        return 1
    fi
}

# is_fzf_available() - Check if fzf is available
# Returns: 0 if available, 1 if not
is_fzf_available() {
    [[ "$FZF_AVAILABLE" == "true" ]]
}

# =============================================================================
# Search Functions
# =============================================================================

# fzf_search_scripts() - Interactive script search with fzf
# Usage: fzf_search_scripts
# Uses global arrays: menu_options, menu_descriptions, menu_commands
# Returns: Selected index in stdout, or empty if cancelled
fzf_search_scripts() {
    if ! is_fzf_available; then
        echo "ERROR: fzf not available" >&2
        return 1
    fi
    
    # Build search list with index, option, and description
    local -a search_items=()
    for i in "${!menu_options[@]}"; do
        local option="${menu_options[$i]}"
        local description="${menu_descriptions[$i]:-}"
        local display="$i|$option|$description"
        search_items+=("$display")
    done
    
    # Use fzf for selection
    local selected
    selected=$(printf '%s\n' "${search_items[@]}" | \
        fzf --height="${FZF_HEIGHT}%" \
            --border \
            --prompt="Search scripts: " \
            --header="Press / to search, Enter to select, Esc to cancel" \
            --delimiter="|" \
            --with-nth=2,3 \
            --preview='echo "Option: {2}\nDescription: {3}"' \
            --preview-window=up:3:wrap \
            --color="fg:#d0d0d0,bg:#121212,hl:#5f87af" \
            --color="fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff" \
            --color="info:#afaf87,prompt:#d7005f,pointer:#af5fff" \
            --color="marker:#87ff00,spinner:#af5fff,header:#87afaf")
    
    if [[ -n "$selected" ]]; then
        # Extract index from selected item
        echo "$selected" | cut -d'|' -f1
        return 0
    else
        return 1
    fi
}

# fzf_search_history() - Search command history with fzf
# Usage: fzf_search_history
# Returns: Selected command in stdout
fzf_search_history() {
    if ! is_fzf_available; then
        echo "ERROR: fzf not available" >&2
        return 1
    fi
    
    local history_file="${HISTORY_FILE:-$HOME/.bashmenu_history.log}"
    
    if [[ ! -f "$history_file" ]]; then
        echo "No history file found" >&2
        return 1
    fi
    
    # Search history with fzf
    local selected
    selected=$(tac "$history_file" | \
        fzf --height="${FZF_HEIGHT}%" \
            --border \
            --prompt="Search history: " \
            --header="Press / to search, Enter to select, Esc to cancel" \
            --preview='echo {}' \
            --preview-window=up:3:wrap \
            --color="fg:#d0d0d0,bg:#121212,hl:#5f87af" \
            --color="fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff" \
            --color="info:#afaf87,prompt:#d7005f,pointer:#af5fff")
    
    if [[ -n "$selected" ]]; then
        echo "$selected"
        return 0
    else
        return 1
    fi
}

# fzf_select_multiple() - Multi-select scripts with fzf
# Usage: fzf_select_multiple
# Uses global arrays: menu_options, menu_descriptions
# Returns: Selected indices (space-separated) in stdout
fzf_select_multiple() {
    if ! is_fzf_available; then
        echo "ERROR: fzf not available" >&2
        return 1
    fi
    
    # Build search list
    local -a search_items=()
    for i in "${!menu_options[@]}"; do
        local option="${menu_options[$i]}"
        local description="${menu_descriptions[$i]:-}"
        local display="$i|$option|$description"
        search_items+=("$display")
    done
    
    # Use fzf with multi-select
    local selected
    selected=$(printf '%s\n' "${search_items[@]}" | \
        fzf --multi \
            --height="${FZF_HEIGHT}%" \
            --border \
            --prompt="Select scripts (Tab to select multiple): " \
            --header="Tab: select, Enter: confirm, Esc: cancel" \
            --delimiter="|" \
            --with-nth=2,3 \
            --preview='echo "Option: {2}\nDescription: {3}"' \
            --preview-window=up:3:wrap \
            --color="fg:#d0d0d0,bg:#121212,hl:#5f87af" \
            --color="fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff" \
            --color="info:#afaf87,prompt:#d7005f,pointer:#af5fff" \
            --color="marker:#87ff00,spinner:#af5fff,header:#87afaf")
    
    if [[ -n "$selected" ]]; then
        # Extract indices and join with spaces
        echo "$selected" | cut -d'|' -f1 | tr '\n' ' '
        return 0
    else
        return 1
    fi
}

# =============================================================================
# Advanced Search Functions
# =============================================================================

# fzf_search_files() - Search for files in a directory
# Usage: fzf_search_files <directory> [pattern]
# Returns: Selected file path in stdout
fzf_search_files() {
    local directory="${1:-.}"
    local pattern="${2:-*}"
    
    if ! is_fzf_available; then
        echo "ERROR: fzf not available" >&2
        return 1
    fi
    
    if [[ ! -d "$directory" ]]; then
        echo "ERROR: Directory not found: $directory" >&2
        return 1
    fi
    
    local selected
    selected=$(find "$directory" -type f -name "$pattern" 2>/dev/null | \
        fzf --height="${FZF_HEIGHT}%" \
            --border \
            --prompt="Select file: " \
            --header="Press / to search, Enter to select, Esc to cancel" \
            --preview='cat {}' \
            --preview-window=right:60%:wrap \
            --color="fg:#d0d0d0,bg:#121212,hl:#5f87af" \
            --color="fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff")
    
    if [[ -n "$selected" ]]; then
        echo "$selected"
        return 0
    else
        return 1
    fi
}

# fzf_search_directories() - Search for directories
# Usage: fzf_search_directories <base_directory>
# Returns: Selected directory path in stdout
fzf_search_directories() {
    local base_dir="${1:-.}"
    
    if ! is_fzf_available; then
        echo "ERROR: fzf not available" >&2
        return 1
    fi
    
    if [[ ! -d "$base_dir" ]]; then
        echo "ERROR: Directory not found: $base_dir" >&2
        return 1
    fi
    
    local selected
    selected=$(find "$base_dir" -type d 2>/dev/null | \
        fzf --height="${FZF_HEIGHT}%" \
            --border \
            --prompt="Select directory: " \
            --header="Press / to search, Enter to select, Esc to cancel" \
            --preview='ls -la {}' \
            --preview-window=right:60%:wrap \
            --color="fg:#d0d0d0,bg:#121212,hl:#5f87af" \
            --color="fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff")
    
    if [[ -n "$selected" ]]; then
        echo "$selected"
        return 0
    else
        return 1
    fi
}

# =============================================================================
# Preview Functions
# =============================================================================

# get_script_preview() - Get preview content for a script
# Usage: get_script_preview <script_path>
# Returns: Preview text in stdout
get_script_preview() {
    local script_path="$1"
    
    if [[ ! -f "$script_path" ]]; then
        echo "Script not found: $script_path"
        return 1
    fi
    
    # Show first 20 lines of script with syntax highlighting if available
    if command -v bat &>/dev/null; then
        bat --color=always --style=numbers --line-range=:20 "$script_path" 2>/dev/null
    elif command -v highlight &>/dev/null; then
        highlight -O ansi --line-range=1-20 "$script_path" 2>/dev/null
    else
        head -n 20 "$script_path"
    fi
}

# fzf_search_with_preview() - Search scripts with enhanced preview
# Usage: fzf_search_with_preview
# Uses global arrays: menu_options, menu_descriptions, menu_commands
# Returns: Selected index in stdout
fzf_search_with_preview() {
    if ! is_fzf_available; then
        echo "ERROR: fzf not available" >&2
        return 1
    fi
    
    # Build search list with script paths
    local -a search_items=()
    for i in "${!menu_options[@]}"; do
        local option="${menu_options[$i]}"
        local description="${menu_descriptions[$i]:-}"
        local command="${menu_commands[$i]:-}"
        
        # Extract script path from command if it's an execute command
        local script_path=""
        if [[ "$command" =~ execute_script:(.+) ]]; then
            script_path="${BASH_REMATCH[1]}"
        elif [[ "$command" =~ execute_auto:(.+) ]]; then
            local script_key="${BASH_REMATCH[1]}"
            script_path="${AUTO_SCRIPTS[${script_key}_path]:-}"
        fi
        
        local display="$i|$option|$description|$script_path"
        search_items+=("$display")
    done
    
    # Use fzf with enhanced preview
    local selected
    selected=$(printf '%s\n' "${search_items[@]}" | \
        fzf --height="${FZF_HEIGHT}%" \
            --border \
            --prompt="Search scripts: " \
            --header="Press / to search, Enter to select, Esc to cancel" \
            --delimiter="|" \
            --with-nth=2,3 \
            --preview='
                script_path=$(echo {} | cut -d"|" -f4)
                if [[ -f "$script_path" ]]; then
                    echo "=== Script Preview ==="
                    echo "Path: $script_path"
                    echo "===================="
                    echo ""
                    if command -v bat &>/dev/null; then
                        bat --color=always --style=numbers --line-range=:20 "$script_path" 2>/dev/null
                    else
                        head -n 20 "$script_path"
                    fi
                else
                    echo "Option: $(echo {} | cut -d"|" -f2)"
                    echo "Description: $(echo {} | cut -d"|" -f3)"
                fi
            ' \
            --preview-window=right:60%:wrap \
            --color="fg:#d0d0d0,bg:#121212,hl:#5f87af" \
            --color="fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff" \
            --color="info:#afaf87,prompt:#d7005f,pointer:#af5fff" \
            --color="marker:#87ff00,spinner:#af5fff,header:#87afaf")
    
    if [[ -n "$selected" ]]; then
        echo "$selected" | cut -d'|' -f1
        return 0
    else
        return 1
    fi
}

# =============================================================================
# Fallback Functions (when fzf not available)
# =============================================================================

# fallback_search() - Simple text-based search fallback
# Usage: fallback_search <query>
# Uses global arrays: menu_options, menu_descriptions
# Returns: Matching indices (newline-separated) in stdout
fallback_search() {
    local query="$1"
    
    if [[ -z "$query" ]]; then
        return 1
    fi
    
    # Search in options and descriptions
    for i in "${!menu_options[@]}"; do
        local option="${menu_options[$i]}"
        local description="${menu_descriptions[$i]:-}"
        
        # Case-insensitive search
        if [[ "${option,,}" == *"${query,,}"* ]] || [[ "${description,,}" == *"${query,,}"* ]]; then
            echo "$i"
        fi
    done
}

# =============================================================================
# Utility Functions
# =============================================================================

# get_fzf_version() - Get fzf version
# Returns: fzf version string
get_fzf_version() {
    if is_fzf_available; then
        fzf --version | head -n1
    else
        echo "fzf not available"
    fi
}

# =============================================================================
# Initialization
# =============================================================================

# Auto-detect fzf on module load
detect_fzf

# =============================================================================
# Export Functions
# =============================================================================

export -f detect_fzf
export -f is_fzf_available
export -f fzf_search_scripts
export -f fzf_search_history
export -f fzf_select_multiple
export -f fzf_search_files
export -f fzf_search_directories
export -f get_script_preview
export -f fzf_search_with_preview
export -f fallback_search
export -f get_fzf_version
