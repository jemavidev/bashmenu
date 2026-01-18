#!/bin/bash

# =============================================================================
# Professional Menu Themes for Bashmenu
# =============================================================================
# Description: Enhanced professional theme system with modern design
# Version:     3.0
# Author:      Enhanced UI Design
# =============================================================================

# =============================================================================
# Professional Theme Definitions
# =============================================================================

# Modern Corporate Theme
theme_modern_corporate() {
    # Colors - Professional blue palette
    export primary_color='\033[38;5;25m'        # Deep blue
    export secondary_color='\033[38;5;67m'     # Medium blue
    export accent_color='\033[38;5;33m'        # Light blue
    export success_color='\033[38;5;34m'       # Green
    export warning_color='\033[38;5;214m'      # Orange
    export error_color='\033[38;5;196m'        # Red
    export text_color='\033[38;5;248m'         # Light gray
    export muted_color='\033[38;5;245m'        # Medium gray
    export background_color='\033[48;5;233m'   # Dark background
    export highlight_color='\033[48;5;240m'    # Selection highlight
    
    # Box characters - Clean modern lines
    export box_h='─'
    export box_v='│'
    export box_tl='┌'
    export box_tr='┐'
    export box_bl='└'
    export box_br='┘'
    export box_cross='┼'
    export box_t_down='┬'
    export box_t_up='┴'
    export box_t_right='├'
    export box_t_left='┤'
    
    # Symbols
    export symbol_success='✓'
    export symbol_error='✗'
    export symbol_warning='⚠'
    export symbol_info='ℹ'
    export symbol_arrow='▶'
    export symbol_bullet='•'
    export symbol_separator='│'
    export symbol_loading='⠋'
}

# Dark Professional Theme
theme_dark_professional() {
    # Colors - Dark mode with high contrast
    export primary_color='\033[38;5;15m'         # White
    export secondary_color='\033[38;5;247m'     # Light gray
    export accent_color='\033[38;5;51m'         # Cyan
    export success_color='\033[38;5;46m'         # Bright green
    export warning_color='\033[38;5;226m'       # Yellow
    export error_color='\033[38;5;203m'         # Bright red
    export text_color='\033[38;5;250m'          # Off-white
    export muted_color='\033[38;5;244m'         # Gray
    export background_color='\033[48;5;232m'   # Black
    export highlight_color='\033[48;5;236m'    # Dark gray highlight
    
    # Box characters - Bold lines
    export box_h='═'
    export box_v='║'
    export box_tl='╔'
    export box_tr='╗'
    export box_bl='╚'
    export box_br='╝'
    export box_cross='╬'
    export box_t_down='╦'
    export box_t_up='╩'
    export box_t_right='╠'
    export box_t_left='╣'
    
    # Symbols
    export symbol_success='✔'
    export symbol_error='✘'
    export symbol_warning='⚠'
    export symbol_info='℘'
    export symbol_arrow='►'
    export bullet='◉'
    export symbol_separator='┆'
    export symbol_loading='⣙'
}

# Minimal Elegant Theme
theme_minimal_elegant() {
    # Colors - Subtle and sophisticated
    export primary_color='\033[38;5;7m'          # Light gray
    export secondary_color='\033[38;5;8m'       # Darker gray
    export accent_color='\033[38;5;6m'          # Cyan
    export success_color='\033[38;5;2m'          # Green
    export warning_color='\033[38;5;3m'          # Yellow
    export error_color='\033[38;5;1m'            # Red
    export text_color='\033[38;5;7m'            # Light gray
    export muted_color='\033[38;5;8m'           # Darker gray
    export background_color=''                  # No background
    export highlight_color='\033[7m'             # Reverse video
    
    # Minimal box - Single thin lines
    export box_h='─'
    export box_v='│'
    export box_tl='┌'
    export box_tr='┐'
    export box_bl='└'
    export box_br='┘'
    export box_cross='┼'
    export box_t_down='┬'
    export box_t_up='┴'
    export box_t_right='├'
    export box_t_left='┤'
    
    # Minimal symbols
    export symbol_success='✓'
    export symbol_error='✗'
    export symbol_warning='!'
    export symbol_info='i'
    export symbol_arrow='>'
    export symbol_bullet='·'
    export symbol_separator='|'
    export symbol_loading='…'
}

# Tech Startup Theme
theme_tech_startup() {
    # Colors - Vibrant tech colors
    export primary_color='\033[38;5;99m'         # Purple
    export secondary_color='\033[38;5;61m'       # Deep purple
    export accent_color='\033[38;5;45m'          # Bright cyan
    export success_color='\033[38;5;35m'         # Bright green
    export warning_color='\033[38;5;215m'       # Bright orange
    export error_color='\033[38;5;197m'         # Bright red
    export text_color='\033[38;5;251m'          # Nearly white
    export muted_color='\033[38;5;246m'         # Light gray
    export background_color='\033[48;5;234m'    # Dark blue background
    export highlight_color='\033[48;5;57m'       # Purple highlight
    
    # Modern box characters
    export box_h='─'
    export box_v='│'
    export box_tl='╭'
    export box_tr='╮'
    export box_bl='╰'
    export box_br='╯'
    export box_cross='┼'
    export box_t_down='┬'
    export box_t_up='┴'
    export box_t_right='├'
    export box_t_left='┤'
    
    # Modern symbols
    export symbol_success='🚀'
    export symbol_error='❌'
    export symbol_warning='⚡'
    export symbol_info='💡'
    export symbol_arrow='▶'
    export symbol_bullet='▪'
    export symbol_separator='┊'
    export symbol_loading='⚡'
}

# =============================================================================
# Professional UI Rendering Functions
# =============================================================================

# render_professional_header() - Render modern header with branding
render_professional_header() {
    local title="$1"
    local subtitle="${2:-}"
    local width=80
    
    # Top border
    echo -e "${primary_color}${box_tl}$(printf "%$((width-2))s" | tr ' ' "$box_h")${box_tr}${NC}"
    
    # Title line with centered text
    local title_padding=$(( (width - ${#title} - 4) / 2 ))
    echo -e "${primary_color}${box_v}${NC}$(printf "%${title_padding}s")${primary_color}${title}$(printf "%$((width - title_padding - ${#title} - 4))s")${box_v}${NC}"
    
    # Subtitle if provided
    if [[ -n "$subtitle" ]]; then
        local subtitle_padding=$(( (width - ${#subtitle} - 4) / 2 ))
        echo -e "${primary_color}${box_v}${NC}$(printf "%${subtitle_padding}s")${secondary_color}${subtitle}$(printf "%$((width - subtitle_padding - ${#subtitle} - 4))s")${box_v}${NC}"
    fi
    
    # Separator
    echo -e "${primary_color}${box_t_right}$(printf "%$((width-2))s" | tr ' ' "$box_h")${box_t_left}${NC}"
}

# render_professional_menu_item() - Render menu item with modern styling
render_professional_menu_item() {
    local index="$1"
    local title="$2"
    local description="${3:-}"
    local is_selected="${4:-false}"
    local width=76
    
    local item_color="$text_color"
    local symbol="$symbol_bullet"
    local bg_color=""
    
    if [[ "$is_selected" == "true" ]]; then
        item_color="$accent_color"
        symbol="$symbol_arrow"
        bg_color="$highlight_color"
    fi
    
    # Main item line
    local item_text=" $symbol [$index] $title"
    local padding=$(( width - ${#item_text} ))
    
    echo -e "${primary_color}${box_v}${NC}${bg_color}${item_color}${item_text}$(printf "%${padding}s")${box_v}${NC}"
    
    # Description line if provided
    if [[ -n "$description" ]]; then
        local desc_text="   ${muted_color}${description}"
        local desc_padding=$(( width - ${#description} - 3 ))
        echo -e "${primary_color}${box_v}${NC}   ${muted_color}${description}$(printf "%${desc_padding}s")${box_v}${NC}"
    fi
}

# render_professional_footer() - Render modern footer with status
render_professional_footer() {
    local status_text="${1:-Ready}"
    local user=$(whoami)
    local hostname=$(hostname)
    local timestamp=$(date '+%H:%M:%S')
    local width=80
    
    # Separator
    echo -e "${primary_color}${box_t_right}$(printf "%$((width-2))s" | tr ' ' "$box_h")${box_t_left}${NC}"
    
    # Footer content
    local footer_content=" ${user}@${hostname} ${symbol_separator} ${timestamp} ${symbol_separator} ${status_text} "
    local footer_padding=$(( width - ${#footer_content} - 2 ))
    
    echo -e "${primary_color}${box_v}${NC}${muted_color}${footer_content}$(printf "%${footer_padding}s")${box_v}${NC}"
    
    # Bottom border
    echo -e "${primary_color}${box_bl}$(printf "%$((width-2))s" | tr ' ' "$box_h")${box_br}${NC}"
}

# render_status_bar() - Render animated status bar
render_status_bar() {
    local message="$1"
    local type="${2:-info}"
    local width=78
    
    local status_symbol status_color
    case "$type" in
        success)
            status_symbol="$symbol_success"
            status_color="$success_color"
            ;;
        warning)
            status_symbol="$symbol_warning"
            status_color="$warning_color"
            ;;
        error)
            status_symbol="$symbol_error"
            status_color="$error_color"
            ;;
        *)
            status_symbol="$symbol_info"
            status_color="$accent_color"
            ;;
    esac
    
    # Status bar background
    echo -e "\r${background_color}${primary_color}${box_tl}$(printf "%$((width-2))s" | tr ' ' "$box_h")${box_tr}${NC}"
    
    # Status content
    local status_content=" ${status_color}${status_symbol} ${text_color}${message} "
    local status_padding=$(( width - ${#message} - 8 ))
    
    echo -e "\r${background_color}${primary_color}${box_v}${status_content}$(printf "%${status_padding}s")${box_v}${NC}"
    echo -e "\r${background_color}${primary_color}${box_bl}$(printf "%$((width-2))s" | tr ' ' "$box_h")${box_br}${NC}"
}

# =============================================================================
# Animation and Transition Effects
# =============================================================================

# smooth_transition() - Smooth screen transition
smooth_transition() {
    local effect="${1:-fade}"
    local lines=$(tput lines)
    local cols=$(tput cols)
    
    case "$effect" in
        "fade")
            for i in {5..1}; do
                tput cup 0 0
                for ((j=0; j<lines; j++)); do
                    echo -e "${muted_color}$(printf "%${cols}s" "")${NC}"
                done
                sleep 0.05
            done
            ;;
        "slide_up")
            for ((i=lines; i>=0; i--)); do
                tput cup "$i" 0
                tput el
                sleep 0.01
            done
            ;;
        "wipe")
            for ((i=0; i<cols; i+=4)); do
                tput cup 0 "$i"
                tput ed
                sleep 0.02
            done
            ;;
    esac
    clear
}

# highlight_transition() - Highlight selected item with animation
highlight_transition() {
    local item_text="$1"
    local duration="${2:-0.3}"
    
    # Simulate selection animation
    for i in {1..3}; do
        echo -e "\r${highlight_color}${primary_color}${symbol_arrow} ${accent_color}${item_text}${NC}"
        sleep $((duration / 3))
        echo -e "\r${text_color}  ${item_text}"
        sleep $((duration / 3))
    done
    echo -e "\r${highlight_color}${primary_color}${symbol_arrow} ${accent_color}${item_text}${NC}"
}

# =============================================================================
# Professional Menu System Integration
# =============================================================================

# display_professional_menu() - Main professional menu display
display_professional_menu() {
    local selected_index="$1"
    local -a menu_items=("${!2}")
    local -a menu_descriptions=("${!3}")
    local title="${4:-Main Menu}"
    local subtitle="${5:-Select an option}"
    
    # Clear screen with transition
    smooth_transition "fade"
    
    # Render header
    render_professional_header "$title" "$subtitle"
    
    # Render menu items
    local index=0
    for item in "${menu_items[@]}"; do
        local description="${menu_descriptions[$index]:-}"
        local is_selected="false"
        
        if [[ $index -eq $selected_index ]]; then
            is_selected="true"
        fi
        
        render_professional_menu_item "$index" "$item" "$description" "$is_selected"
        ((index++))
    done
    
    # Render footer
    render_status_bar "Use ↑↓ to navigate • Enter to select • q to quit"
    render_professional_footer
}

# =============================================================================
# Loading and Progress Indicators
# =============================================================================

# professional_spinner() - Modern loading spinner
professional_spinner() {
    local message="$1"
    local duration="${2:-}"
    local style="${3:-dots}"
    
    local -a spinners=(
        "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
        "⣾⣽⣻⢿⡿⣟⣯⣷"
        "◐◓◑◒"
        "▌▀▐▄"
        "┤┘┴└├┌┬┐"
    )
    
    local spinner="${spinners[$((style % ${#spinners[@]}))]}"
    local i=0
    
    tput civis  # Hide cursor
    
    while [[ -z "$duration" ]] || [[ $i -lt $((duration * 10)) ]]; do
        local char="${spinner:$((i % ${#spinner})):1}"
        echo -ne "\r${accent_color}${char}${NC} ${text_color}${message}${NC}"
        sleep 0.1
        ((i++))
    done
    
    tput cnorm  # Show cursor
    echo -ne "\r$(printf "%$(tput cols)s")\r"  # Clear line
}

# professional_progress_bar() - Enhanced progress bar
professional_progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local label="${4:-Progress}"
    
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    # Color based on progress
    local bar_color
    if [[ $percentage -lt 33 ]]; then
        bar_color="$error_color"
    elif [[ $percentage -lt 66 ]]; then
        bar_color="$warning_color"
    else
        bar_color="$success_color"
    fi
    
    # Build progress bar
    echo -ne "\r${text_color}${label}:${NC} ["
    echo -ne "${bar_color}$(printf "%${filled}s" | tr ' ' '█')${NC}"
    echo -ne "$(printf "%${empty}s" | tr ' ' '░')"
    echo -ne "] ${bar_color}${percentage}%${NC}"
}

# =============================================================================
# Theme Loading System
# =============================================================================

# load_professional_theme() - Load a professional theme
load_professional_theme() {
    local theme_name="${1:-modern_corporate}"
    
    case "$theme_name" in
        "modern_corporate")
            theme_modern_corporate
            ;;
        "dark_professional")
            theme_dark_professional
            ;;
        "minimal_elegant")
            theme_minimal_elegant
            ;;
        "tech_startup")
            theme_tech_startup
            ;;
        *)
            theme_modern_corporate  # Default theme
            ;;
    esac
    
    export CURRENT_PROFESSIONAL_THEME="$theme_name"
}

# =============================================================================
# Export Functions
# =============================================================================

export -f theme_modern_corporate
export -f theme_dark_professional
export -f theme_minimal_elegant
export -f theme_tech_startup
export -f render_professional_header
export -f render_professional_menu_item
export -f render_professional_footer
export -f render_status_bar
export -f smooth_transition
export -f highlight_transition
export -f display_professional_menu
export -f professional_spinner
export -f professional_progress_bar
export -f load_professional_theme