#!/bin/bash

# =============================================================================
# Enhanced Professional Menu Display for Bashmenu
# =============================================================================
# Description: Modern, professional menu system with enhanced UX
# Version:     3.0
# =============================================================================

# Strict mode for better error handling
set -euo pipefail

# Source professional themes
source "$(dirname "${BASH_SOURCE[0]}")/professional_themes.sh"

# =============================================================================
# Enhanced Menu State Management
# =============================================================================

# Menu state variables
declare -g MENU_SELECTED_INDEX=0
declare -g MENU_PAGE_SIZE=10
declare -g MENU_TOTAL_ITEMS=0
declare -g MENU_CURRENT_PAGE=0
declare -g MENU_TOTAL_PAGES=0
declare -g MENU_SEARCH_QUERY=""
declare -g MENU_FILTERED_ITEMS=()

# =============================================================================
# Enhanced Menu Display Functions
# =============================================================================

# display_enhanced_menu() - Main enhanced menu display function
display_enhanced_menu() {
    local -a menu_items=("${!1}")
    local -a menu_descriptions=("${!2}")
    local menu_title="${3:-Main Menu}"
    local menu_subtitle="${4:-Select an option}"
    local theme_name="${5:-modern_corporate}"
    
    # Load professional theme
    load_professional_theme "$theme_name"
    
    # Calculate pagination
    MENU_TOTAL_ITEMS=${#menu_items[@]}
    MENU_TOTAL_PAGES=$(( (MENU_TOTAL_ITEMS + MENU_PAGE_SIZE - 1) / MENU_PAGE_SIZE ))
    MENU_CURRENT_PAGE=$((MENU_SELECTED_INDEX / MENU_PAGE_SIZE))
    
    # Clear screen with smooth transition
    smooth_transition "fade"
    
    # Render header
    render_professional_header "$menu_title" "$menu_subtitle"
    
    # Render menu items for current page
    render_menu_page "$MENU_SELECTED_INDEX" menu_items menu_descriptions
    
    # Render pagination info if needed
    if [[ $MENU_TOTAL_PAGES -gt 1 ]]; then
        render_pagination_info
    fi
    
    # Render footer with enhanced controls
    render_enhanced_footer
}

# render_menu_page() - Render items for current page
render_menu_page() {
    local selected_index="$1"
    local -a items=("${!2}")
    local -a descriptions=("${!3}")
    
    local start_index=$((MENU_CURRENT_PAGE * MENU_PAGE_SIZE))
    local end_index=$((start_index + MENU_PAGE_SIZE - 1))
    
    if [[ $end_index -ge $MENU_TOTAL_ITEMS ]]; then
        end_index=$((MENU_TOTAL_ITEMS - 1))
    fi
    
    # Render items in current page
    for ((i=start_index; i<=end_index; i++)); do
        local item="${items[$i]}"
        local description="${descriptions[$i]:-}"
        local is_selected="false"
        
        if [[ $i -eq $selected_index ]]; then
            is_selected="true"
        fi
        
        render_professional_menu_item "$i" "$item" "$description" "$is_selected"
    done
    
    # Add empty lines if page is not full
    local items_on_page=$((end_index - start_index + 1))
    local empty_slots=$((MENU_PAGE_SIZE - items_on_page))
    
    for ((i=0; i<empty_slots; i++)); do
        echo -e "${primary_color}${box_v}${NC}$(printf "%76s")${box_v}${NC}"
    done
}

# render_pagination_info() - Show pagination information
render_pagination_info() {
    local current_page_display=$((MENU_CURRENT_PAGE + 1))
    local page_info="Page $current_page_display/$MENU_TOTAL_PAGES (Items: $((MENU_CURRENT_PAGE * MENU_PAGE_SIZE + 1))-$((end_index + 1))/$MENU_TOTAL_ITEMS)"
    
    echo -e "${primary_color}${box_t_right}$(printf "%78s" | tr ' ' "$box_h")${box_t_left}${NC}"
    echo -e "${primary_color}${box_v}${NC} ${accent_color}${page_info}$(printf "%$((76 - ${#page_info}))s")${box_v}${NC}"
}

# render_enhanced_footer() - Enhanced footer with comprehensive controls
render_enhanced_footer() {
    local user=$(whoami)
    local hostname=$(hostname)
    local timestamp=$(date '+%H:%M:%S')
    
    # Controls info
    local controls="↑↓ Navigate • PageUp/Down Fast scroll • Home/End First/Last • Enter Select • q Quit"
    local advanced_controls="s Search • h Help • t Themes • r Refresh • d Dashboard"
    
    # Separator
    echo -e "${primary_color}${box_t_right}$(printf "%78s" | tr ' ' "$box_h")${box_t_left}${NC}"
    
    # Controls line
    echo -e "${primary_color}${box_v}${NC} ${muted_color}${controls}$(printf "%$((76 - ${#controls}))s")${box_v}${NC}"
    
    # Advanced controls line
    echo -e "${primary_color}${box_v}${NC} ${secondary_color}${advanced_controls}$(printf "%$((76 - ${#advanced_controls}))s")${box_v}${NC}"
    
    # Footer separator
    echo -e "${primary_color}${box_t_right}$(printf "%78s" | tr ' ' "$box_h")${box_t_left}${NC}"
    
    # Footer with system info
    local footer_content=" ${user}@${hostname} ${symbol_separator} ${timestamp} ${symbol_separator} Theme: ${CURRENT_PROFESSIONAL_THEME} "
    local footer_padding=$((78 - ${#footer_content}))
    
    echo -e "${primary_color}${box_v}${NC}${muted_color}${footer_content}$(printf "%${footer_padding}s")${box_v}${NC}"
    
    # Bottom border
    echo -e "${primary_color}${box_bl}$(printf "%78s" | tr ' ' "$box_h")${box_br}${NC}"
}

# =============================================================================
# Search and Filter Functions
# =============================================================================

# display_search_interface() - Show search interface
display_search_interface() {
    local -a menu_items=("${!1}")
    local -a menu_descriptions=("${!2}")
    
    # Search header
    render_professional_header "Search Menu" "Type to filter options"
    
    # Search input field
    echo -e "${primary_color}${box_v}${NC} ${accent_color}Search:${NC} ${MENU_SEARCH_QUERY}_$(printf "%$((70 - ${#MENU_SEARCH_QUERY}))s")${box_v}${NC}"
    echo -e "${primary_color}${box_t_right}$(printf "%78s" | tr ' ' "$box_h")${box_t_left}${NC}"
    
    # Filtered results
    if [[ -n "$MENU_SEARCH_QUERY" ]]; then
        filter_menu_items menu_items menu_descriptions
        
        if [[ ${#MENU_FILTERED_ITEMS[@]} -gt 0 ]]; then
            echo -e "${primary_color}${box_v}${NC} ${success_color}Found ${#MENU_FILTERED_ITEMS[@]} matching items:${NC}$(printf "%$((58 - ${#MENU_FILTERED_ITEMS[@]}))s")${box_v}${NC}"
            
            local index=0
            for item_index in "${MENU_FILTERED_ITEMS[@]}"; do
                local item="${menu_items[$item_index]}"
                local description="${menu_descriptions[$item_index]:-}"
                
                # Highlight matching text
                if [[ $item == *"$MENU_SEARCH_QUERY"* ]]; then
                    highlighted_item="${item//$MENU_SEARCH_QUERY/${accent_color}${MENU_SEARCH_QUERY}${text_color}}"
                else
                    highlighted_item="$item"
                fi
                
                echo -e "${primary_color}${box_v}${NC}   ${text_color}[$item_index] ${highlighted_item}$(printf "%$((65 - ${#item}))s")${box_v}${NC}"
                
                if [[ -n "$description" ]]; then
                    echo -e "${primary_color}${box_v}${NC}      ${muted_color}${description}$(printf "%$((71 - ${#description}))s")${box_v}${NC}"
                fi
                
                ((index++))
                if [[ $index -ge 8 ]]; then break; fi  # Limit results display
            done
        else
            echo -e "${primary_color}${box_v}${NC} ${error_color}No matching items found${NC}$(printf "%52s")${box_v}${NC}"
        fi
    else
        echo -e "${primary_color}${box_v}${NC} ${muted_color}Start typing to search...${NC}$(printf "%55s")${box_v}${NC}"
    fi
    
    render_professional_footer "ESC to exit search • Tab to select"
}

# filter_menu_items() - Filter menu items based on search query
filter_menu_items() {
    local -a items=("${!1}")
    local -a descriptions=("${!2}")
    
    MENU_FILTERED_ITEMS=()
    
    for ((i=0; i<${#items[@]}; i++)); do
        local item="${items[$i]}"
        local description="${descriptions[$i]:-}"
        
        # Check if item or description matches search query
        if [[ -n "$MENU_SEARCH_QUERY" ]]; then
            if [[ "$item" == *"$MENU_SEARCH_QUERY"* ]] || [[ "$description" == *"$MENU_SEARCH_QUERY"* ]]; then
                MENU_FILTERED_ITEMS+=("$i")
            fi
        fi
    done
}

# =============================================================================
# Theme Selection Interface
# =============================================================================

# display_theme_selector() - Show theme selection interface
display_theme_selector() {
    local current_theme="${CURRENT_PROFESSIONAL_THEME:-modern_corporate}"
    
    render_professional_header "Theme Selection" "Choose your preferred visual theme"
    
    local -a themes=("modern_corporate" "dark_professional" "minimal_elegant" "tech_startup")
    local -a theme_descriptions=(
        "Professional blue theme with clean lines"
        "Dark mode with high contrast"
        "Minimal and elegant design"
        "Vibrant tech startup colors"
    )
    
    for ((i=0; i<${#themes[@]}; i++)); do
        local theme="${themes[$i]}"
        local description="${theme_descriptions[$i]}"
        local is_selected="false"
        
        if [[ "$theme" == "$current_theme" ]]; then
            is_selected="true"
        fi
        
        render_professional_menu_item "$i" "$theme" "$description" "$is_selected"
    done
    
    render_professional_footer "↑↓ Navigate • Enter to apply • ESC to cancel"
}

# =============================================================================
# Help System
# =============================================================================

# display_enhanced_help() - Show comprehensive help
display_enhanced_help() {
    render_professional_header "Help & Shortcuts" "Complete navigation guide"
    
    echo -e "${primary_color}${box_v}${NC} ${accent_color}Navigation:${NC}$(printf "%60s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_arrow} Up/Down     ${text_color}Navigate menu items$(printf "%46s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_arrow} PageUp/Down ${text_color}Fast scroll (10 items at a time)$(printf "%35s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_arrow} Home/End    ${text_color}Jump to first/last item$(printf "%42s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_arrow} Number      ${text_color}Jump directly to item by number$(printf "%39s")${box_v}${NC}"
    echo ""
    
    echo -e "${primary_color}${box_v}${NC} ${accent_color}Actions:${NC}$(printf "%63s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_arrow} Enter       ${text_color}Execute selected item$(printf "%45s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_arrow} q           ${text_color}Quit menu$(printf "%55s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_arrow} s           ${text_color}Search menu items$(printf "%48s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_arrow} h           ${text_color}Show this help$(printf "%53s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_arrow} t           ${text_color}Change theme$(printf "%54s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_arrow} r           ${text_color}Refresh menu$(printf "%51s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_arrow} d           ${text_color}Show dashboard$(printf "%50s")${box_v}${NC}"
    echo ""
    
    echo -e "${primary_color}${box_v}${NC} ${accent_color}Search Mode:${NC}$(printf "%56s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_arrow} Type        ${text_color}Filter menu items$(printf "%49s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_arrow} Tab         ${text_color}Select first match$(printf "%49s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_arrow} ESC         ${text_color}Exit search$(printf "%54s")${box_v}${NC}"
    echo ""
    
    echo -e "${primary_color}${box_v}${NC} ${accent_color}Tips:${NC}$(printf "%65s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_bullet} ${text_color}Hold Shift for faster scrolling$(printf "%43s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_bullet} ${text_color}Use search to quickly find options$(printf "%44s")${box_v}${NC}"
    echo -e "${primary_color}${box_v}${NC}   ${symbol_bullet} ${text_color}Themes affect all visual elements$(printf "%42s")${box_v}${NC}"
    
    render_professional_footer "Press any key to return to menu"
}

# =============================================================================
# Status and Notification System
# =============================================================================

# show_status_notification() - Show temporary status notification
show_status_notification() {
    local message="$1"
    local type="${2:-info}"
    local duration="${3:-2}"
    
    # Save cursor position
    tput sc
    
    # Move to top of screen (line 3 to avoid overwriting header)
    tput cup 2 0
    
    # Create notification box
    local notification_width=$((${#message} + 8))
    local padding=$(((80 - notification_width) / 2))
    
    echo -ne "$(printf "%${padding}s")"
    echo -e "${accent_color}${box_tl}$(printf "%$((notification_width-2))s" | tr ' ' "$box_h")${box_tr}${NC}"
    
    echo -ne "$(printf "%${padding}s")"
    local icon
    case "$type" in
        success) icon="$symbol_success" ;;
        warning) icon="$symbol_warning" ;;
        error) icon="$symbol_error" ;;
        *) icon="$symbol_info" ;;
    esac
    
    echo -e "${accent_color}${box_v}${NC} ${icon} ${message} ${accent_color}${box_v}${NC}"
    
    echo -ne "$(printf "%${padding}s")"
    echo -e "${accent_color}${box_bl}$(printf "%$((notification_width-2))s" | tr ' ' "$box_h")${box_br}${NC}"
    
    # Auto-hide after duration
    if [[ $duration -gt 0 ]]; then
        (
            sleep "$duration"
            tput sc
            tput cup 2 0
            for ((i=0; i<3; i++)); do
                tput el
                tput cud 1
            done
            tput rc
        ) &
    fi
    
    # Restore cursor position
    tput rc
}

# =============================================================================
# Integration Functions
# =============================================================================

# enhanced_menu_loop() - Enhanced main menu loop
enhanced_menu_loop() {
    local -a menu_items=("${!1}")
    local -a menu_descriptions=("${!2}")
    local menu_title="${3:-Main Menu}"
    local menu_subtitle="${4:-Select an option}"
    local theme_name="${5:-modern_corporate}"
    
    local key
    local search_mode=false
    local theme_mode=false
    local help_mode=false
    
    # Initialize
    MENU_SELECTED_INDEX=0
    load_professional_theme "$theme_name"
    
    while true; do
        # Display appropriate interface
        if [[ "$search_mode" == "true" ]]; then
            display_search_interface menu_items menu_descriptions
        elif [[ "$theme_mode" == "true" ]]; then
            display_theme_selector
        elif [[ "$help_mode" == "true" ]]; then
            display_enhanced_help
        else
            display_enhanced_menu "$MENU_SELECTED_INDEX" menu_items menu_descriptions "$menu_title" "$menu_subtitle" "$theme_name"
        fi
        
        # Read input
        read -rsn1 key
        
        # Handle input based on mode
        if [[ "$search_mode" == "true" ]]; then
            case "$key" in
                $'\x1b')  # ESC
                    search_mode=false
                    MENU_SEARCH_QUERY=""
                    ;;
                $'\x09')  # Tab
                    if [[ ${#MENU_FILTERED_ITEMS[@]} -gt 0 ]]; then
                        MENU_SELECTED_INDEX="${MENU_FILTERED_ITEMS[0]}"
                        search_mode=false
                        MENU_SEARCH_QUERY=""
                        show_status_notification "Selected: ${menu_items[$MENU_SELECTED_INDEX]}" "success"
                    fi
                    ;;
                [a-zA-Z0-9\ ])
                    MENU_SEARCH_QUERY+="$key"
                    ;;
                $'\x7f')  # Backspace
                    MENU_SEARCH_QUERY="${MENU_SEARCH_QUERY%?}"
                    ;;
            esac
        elif [[ "$theme_mode" == "true" ]]; then
            case "$key" in
                $'\x1b')  # ESC
                    theme_mode=false
                    ;;
                $'\x0a')  # Enter
                    local -a themes=("modern_corporate" "dark_professional" "minimal_elegant" "tech_startup")
                    local selected_theme="${themes[$MENU_SELECTED_INDEX]}"
                    load_professional_theme "$selected_theme"
                    theme_mode=false
                    show_status_notification "Theme changed to: $selected_theme" "success"
                    ;;
                $'\x1b[A')  # Up
                    ((MENU_SELECTED_INDEX--))
                    if [[ $MENU_SELECTED_INDEX -lt 0 ]]; then MENU_SELECTED_INDEX=3; fi
                    ;;
                $'\x1b[B')  # Down
                    ((MENU_SELECTED_INDEX++))
                    if [[ $MENU_SELECTED_INDEX -gt 3 ]]; then MENU_SELECTED_INDEX=0; fi
                    ;;
            esac
        elif [[ "$help_mode" == "true" ]]; then
            help_mode=false  # Exit help on any key
        else
            # Normal menu navigation
            case "$key" in
                $'\x1b')  # ESC sequence start
                    read -rsn2 -t 0.1 key
                    case "$key" in
                        "[A")  # Up arrow
                            ((MENU_SELECTED_INDEX--))
                            if [[ $MENU_SELECTED_INDEX -lt 0 ]]; then 
                                MENU_SELECTED_INDEX=$((MENU_TOTAL_ITEMS - 1))
                            fi
                            ;;
                        "[B")  # Down arrow
                            ((MENU_SELECTED_INDEX++))
                            if [[ $MENU_SELECTED_INDEX -ge $MENU_TOTAL_ITEMS ]]; then 
                                MENU_SELECTED_INDEX=0
                            fi
                            ;;
                        "[5") # PageUp
                            MENU_SELECTED_INDEX=$((MENU_SELECTED_INDEX - MENU_PAGE_SIZE))
                            if [[ $MENU_SELECTED_INDEX -lt 0 ]]; then MENU_SELECTED_INDEX=0; fi
                            ;;
                        "[6") # PageDown
                            MENU_SELECTED_INDEX=$((MENU_SELECTED_INDEX + MENU_PAGE_SIZE))
                            if [[ $MENU_SELECTED_INDEX -ge $MENU_TOTAL_ITEMS ]]; then 
                                MENU_SELECTED_INDEX=$((MENU_TOTAL_ITEMS - 1))
                            fi
                            ;;
                        "[H"|"1~") # Home
                            MENU_SELECTED_INDEX=0
                            ;;
                        "[F"|"4~") # End
                            MENU_SELECTED_INDEX=$((MENU_TOTAL_ITEMS - 1))
                            ;;
                    esac
                    ;;
                $'\x0a')  # Enter
                    echo "$MENU_SELECTED_INDEX"
                    return 0
                    ;;
                "q")  # Quit
                    return 1
                    ;;
                "s")  # Search
                    search_mode=true
                    MENU_SEARCH_QUERY=""
                    ;;
                "h")  # Help
                    help_mode=true
                    ;;
                "t")  # Theme
                    theme_mode=true
                    MENU_SELECTED_INDEX=0
                    ;;
                "r")  # Refresh
                    show_status_notification "Menu refreshed" "info"
                    ;;
                "d")  # Dashboard
                    if declare -f show_dashboard >/dev/null 2>&1; then
                        show_dashboard
                        show_status_notification "Dashboard displayed" "info"
                    else
                        show_status_notification "Dashboard not available" "warning"
                    fi
                    ;;
                [0-9])
                    # Direct number selection
                    local num="${key}"
                    read -rsn1 -t 0.5 next_char
                    if [[ "$next_char" =~ [0-9] ]]; then
                        num="${num}${next_char}"
                    fi
                    
                    local num_index=$((num - 1))
                    if [[ $num_index -ge 0 ]] && [[ $num_index -lt $MENU_TOTAL_ITEMS ]]; then
                        MENU_SELECTED_INDEX=$num_index
                        echo "$MENU_SELECTED_INDEX"
                        return 0
                    else
                        show_status_notification "Invalid selection: $num" "error"
                    fi
                    ;;
            esac
        fi
    done
}

# =============================================================================
# Export Functions
# =============================================================================

export -f display_enhanced_menu
export -f display_search_interface
export -f display_theme_selector
export -f display_enhanced_help
export -f enhanced_menu_loop
export -f show_status_notification
export -f filter_menu_items