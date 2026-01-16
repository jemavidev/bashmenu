#!/bin/bash

# =============================================================================
# Menu Display Module for Bashmenu
# =============================================================================
# Description: Extracted display logic from menu_loop functions
# Version:     1.0
# =============================================================================

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Menu Display Functions
# =============================================================================

# Display classic menu
display_classic_menu() {
    local selected_index=$1
    local i
    
    echo ""
    echo -e "${title_color}┌─────────────────────────────────────────────────────┐${NC}"
    echo -e "${title_color}│${NC} ${success_color}           SYSTEM ADMINISTRATION MENU           ${NC}${title_color}│${NC}"
    echo -e "${title_color}├─────────────────────────────────────────────────────┤${NC}"
    
    for i in "${!menu_options[@]}"; do
        local option="${menu_options[$i]}"
        local description="${menu_descriptions[$i]:-}"
        
        if [[ $i -eq $selected_index ]]; then
            echo -e "${title_color}│${NC} ${select_color}► [$i]${NC} ${select_color}${option}${NC}"
        else
            echo -e "${title_color}│${NC}     [$i] ${option}"
        fi
        
        if [[ -n "$description" ]]; then
            if [[ $i -eq $selected_index ]]; then
                echo -e "${title_color}│${NC}          ${description_color}${description}${NC}"
            else
                echo -e "${title_color}│${NC}          ${description_color}${description}${NC}"
            fi
        fi
    done
    
    echo -e "${title_color}├─────────────────────────────────────────────────────┤${NC}"
    echo -e "${title_color}│${NC} ${info_color}[Controls] ↑↓ Navigate | Enter Select | q Quit${NC}${title_color}│${NC}"
    echo -e "${title_color}│${NC} ${info_color}          d Dashboard | s Status | r Refresh${NC}${title_color}│${NC}"
    echo -e "${title_color}└─────────────────────────────────────────────────────┘${NC}"
}

# Display hierarchical menu
display_hierarchical_menu() {
    local selected_index=$1
    local i
    local current_path="${CURRENT_PATH:-/}"
    
    echo ""
    echo -e "${title_color}┌─────────────────────────────────────────────────────┐${NC}"
    echo -e "${title_color}│${NC} ${success_color}           SYSTEM ADMINISTRATION MENU           ${NC}${title_color}│${NC}"
    echo -e "${title_color}├─────────────────────────────────────────────────────┤${NC}"
    
    # Show breadcrumb
    echo -e "${title_color}│${NC} ${info_color}Path: ${current_path}${NC}${title_color}│${NC}"
    echo -e "${title_color}├─────────────────────────────────────────────────────┤${NC}"
    
    for i in "${!menu_items[@]}"; do
        local item="${menu_items[$i]}"
        local item_type="${menu_hierarchy[$current_path/$item]:-unknown}"
        
        if [[ $i -eq $selected_index ]]; then
            case "$item_type" in
                "directory")
                    echo -e "${title_color}│${NC} ${select_color}► [$i]${NC} ${select_color}${item}/${NC}"
                    ;;
                "script")
                    echo -e "${title_color}│${NC} ${select_color}► [$i]${NC} ${select_color}${item}${NC}"
                    ;;
                *)
                    echo -e "${title_color}│${NC} ${select_color}► [$i]${NC} ${select_color}${item}${NC}"
                    ;;
            esac
        else
            case "$item_type" in
                "directory")
                    echo -e "${title_color}│${NC}     [$i] ${item}/"
                    ;;
                "script")
                    echo -e "${title_color}│${NC}     [$i] ${item}"
                    ;;
                *)
                    echo -e "${title_color}│${NC}     [$i] ${item}"
                    ;;
            esac
        fi
    done
    
    echo -e "${title_color}├─────────────────────────────────────────────────────┤${NC}"
    echo -e "${title_color}│${NC} ${info_color}[Controls] ↑↓ Navigate | Enter Select | q Quit${NC}${title_color}│${NC}"
    echo -e "${title_color}│${NC} ${info_color}          b Back | d Dashboard | s Status${NC}${title_color}│${NC}"
    echo -e "${title_color}└─────────────────────────────────────────────────────┘${NC}"
}

# Display menu header
display_menu_header() {
    echo ""
    echo -e "${title_color}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${title_color}║${NC} ${success_color}              BASHMENU v2.1${NC} ${title_color}                    ║${NC}"
    echo -e "${title_color}║${NC} ${info_color}         System Administration Tool${NC} ${title_color}               ║${NC}"
    echo -e "${title_color}╚════════════════════════════════════════════════════════╝${NC}"
}

# Display menu footer
display_menu_footer() {
    local current_time=$(date '+%Y-%m-%d %H:%M:%S')
    local user=$(whoami)
    local hostname=$(hostname)
    
    echo ""
    echo -e "${info_color}┌─────────────────────────────────────────────────────┐${NC}"
    echo -e "${info_color}│${NC} User: ${user}@${hostname} | Time: ${current_time} ${info_color}│${NC}"
    echo -e "${info_color}└─────────────────────────────────────────────────────┘${NC}"
}

# Refresh menu display
refresh_menu_display() {
    local menu_type="$1"
    local selected_index="$2"
    
    # Clear screen
    clear
    
    # Display components
    display_menu_header
    
    case "$menu_type" in
        "classic")
            display_classic_menu "$selected_index"
            ;;
        "hierarchical")
            display_hierarchical_menu "$selected_index"
            ;;
        *)
            if declare -f log_error >/dev/null; then
                log_error "Unknown menu type: $menu_type"
            fi
            return 1
            ;;
    esac
    
    display_menu_footer
}

# Show menu help
show_menu_help() {
    local menu_type="$1"
    
    clear
    echo -e "${title_color}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${title_color}║${NC} ${success_color}                   MENU HELP${NC} ${title_color}                      ║${NC}"
    echo -e "${title_color}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${info_color}Navigation:${NC}"
    echo -e "  ${arrow_color}↑/↓${NC}  Navigate menu items"
    echo -e "  ${arrow_color}Page Up/Down${NC}  Navigate faster"
    echo -e "  ${arrow_color}Home/End${NC}  Jump to first/last item"
    echo -e "  ${arrow_color}Number${NC}  Select item by number"
    echo ""
    
    echo -e "${info_color}Actions:${NC}"
    echo -e "  ${arrow_color}Enter${NC}  Execute selected item"
    echo -e "  ${arrow_color}q${NC}  Quit menu"
    
    if [[ "$menu_type" == "hierarchical" ]]; then
        echo -e "  ${arrow_color}b${NC}  Go back to parent directory"
    fi
    
    echo -e "  ${arrow_color}d${NC}  Show dashboard"
    echo -e "  ${arrow_color}s${NC}  Show system status"
    echo -e "  ${arrow_color}r${NC}  Refresh menu"
    echo ""
    
    echo -e "${info_color}Press any key to return to menu...${NC}"
    read -n 1 -s
}

# Export functions
export -f display_classic_menu
export -f display_hierarchical_menu
export -f display_menu_header
export -f display_menu_footer
export -f refresh_menu_display
export -f show_menu_help