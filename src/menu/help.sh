#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Menu Help - Bashmenu
# =============================================================================
# Description: Help system and documentation display
# Version:     3.0
# Author:      JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Help Display Functions
# =============================================================================

# show_help_screen() -> void
# Display comprehensive help screen
show_help_screen() {
    clear_screen
    
    # Display header
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                    ${BOLD_CYAN:-$CYAN}BASHMENU HELP${NC}                          ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Navigation shortcuts
    display_navigation_help
    
    # Command shortcuts
    display_command_help
    
    # Features
    display_features_help
    
    # Configuration
    display_configuration_help
    
    # Optional dependencies
    display_dependencies_help
    
    # Footer
    echo ""
    echo -e "${success_color:-$GREEN}Press any key to return to menu...${NC}"
    read -s -n1
}

# =============================================================================
# Help Section Functions
# =============================================================================

# display_navigation_help() -> void
# Display navigation help section
display_navigation_help() {
    echo -e "${BOLD_GREEN:-$GREEN}Navigation:${NC}"
    echo -e "  ${selected_color:-$GREEN}↑/↓${NC}         Navigate up/down through menu items"
    echo -e "  ${selected_color:-$GREEN}Home/End${NC}    Jump to first/last item"
    echo -e "  ${success_color:-$GREEN}Enter${NC}       Select and execute current item"
    echo ""
}

# display_command_help() -> void
# Display command help section
display_command_help() {
    echo -e "${BOLD_GREEN:-$GREEN}Commands:${NC}"
    echo -e "  ${CYAN}/${NC}           Search scripts (requires fzf)"
    echo -e "  ${CYAN}?${NC}           Show this help screen"
    echo -e "  ${BLUE}d${NC}           Open system dashboard"
    echo -e "  ${BLUE}s${NC}           Show quick status"
    echo -e "  ${BLUE}r${NC}           Refresh menu"
    echo -e "  ${error_color:-$RED}q${NC}           Quit Bashmenu"
    echo ""
}

# display_features_help() -> void
# Display features help section
display_features_help() {
    echo -e "${BOLD_GREEN:-$GREEN}Features:${NC}"
    echo -e "  • Hierarchical menu navigation"
    echo -e "  • Auto-detected scripts from plugin directories"
    echo -e "  • Manual script configuration support"
    echo -e "  • Enhanced UI with animations and colors"
    echo -e "  • Dialog/Whiptail graphical interface (if available)"
    echo -e "  • Interactive search with fzf (if available)"
    echo -e "  • Desktop notifications (if available)"
    echo ""
}

# display_configuration_help() -> void
# Display configuration help section
display_configuration_help() {
    echo -e "${BOLD_GREEN:-$GREEN}Configuration:${NC}"
    echo -e "  Config file: ${CYAN}config/config.conf${NC}"
    echo -e "  UI Mode:     ${CYAN}${UI_MODE:-auto}${NC}"
    echo -e "  Theme:       ${CYAN}${DEFAULT_THEME:-modern}${NC}"
    echo ""
}

# display_dependencies_help() -> void
# Display optional dependencies status
display_dependencies_help() {
    echo -e "${BOLD_GREEN:-$GREEN}Optional Dependencies:${NC}"
    
    # Check fzf
    if command -v fzf >/dev/null 2>&1; then
        echo -e "  ${success_color:-$GREEN}✓${NC} fzf (fuzzy search)"
    else
        echo -e "  ${error_color:-$RED}✗${NC} fzf (fuzzy search) - Install: sudo apt install fzf"
    fi
    
    # Check dialog
    if command -v dialog >/dev/null 2>&1; then
        echo -e "  ${success_color:-$GREEN}✓${NC} dialog (graphical UI)"
    else
        echo -e "  ${error_color:-$RED}✗${NC} dialog (graphical UI) - Install: sudo apt install dialog"
    fi
    
    # Check notify-send
    if command -v notify-send >/dev/null 2>&1; then
        echo -e "  ${success_color:-$GREEN}✓${NC} notify-send (desktop notifications)"
    else
        echo -e "  ${error_color:-$RED}✗${NC} notify-send (desktop notifications) - Install: sudo apt install libnotify-bin"
    fi
    
    echo ""
}

# =============================================================================
# Quick Help Functions
# =============================================================================

# show_quick_help() -> void
# Display quick help banner
show_quick_help() {
    echo ""
    echo -e "${info_color:-$BLUE}Quick Help:${NC}"
    echo -e "  ↑↓ Navigate • Enter Select • / Search • ? Help • q Quit"
    echo ""
}

# show_keyboard_shortcuts() -> void
# Display keyboard shortcuts reference
show_keyboard_shortcuts() {
    echo -e "${BOLD_GREEN:-$GREEN}Keyboard Shortcuts:${NC}"
    echo ""
    echo -e "  ${CYAN}Navigation:${NC}"
    echo -e "    ↑/↓       Move selection up/down"
    echo -e "    Home/End  Jump to first/last item"
    echo -e "    Enter     Execute selected item"
    echo ""
    echo -e "  ${CYAN}Commands:${NC}"
    echo -e "    /         Search (requires fzf)"
    echo -e "    ?         Show help"
    echo -e "    d         Dashboard"
    echo -e "    s         Quick status"
    echo -e "    r         Refresh menu"
    echo -e "    q         Quit"
    echo ""
}

# =============================================================================
# Context-Sensitive Help
# =============================================================================

# show_context_help() -> void
# Display context-sensitive help based on current state
# Args:
#   $1 - Context (menu, search, dashboard, etc.)
show_context_help() {
    local context="${1:-menu}"
    
    case "$context" in
        menu)
            show_menu_help
            ;;
        search)
            show_search_help
            ;;
        dashboard)
            show_dashboard_help
            ;;
        *)
            show_quick_help
            ;;
    esac
}

# show_menu_help() -> void
# Display menu-specific help
show_menu_help() {
    echo -e "${info_color:-$BLUE}Menu Help:${NC}"
    echo "  Use arrow keys to navigate, Enter to select"
    echo "  Press '/' to search, '?' for full help"
}

# show_search_help() -> void
# Display search-specific help
show_search_help() {
    echo -e "${info_color:-$BLUE}Search Help:${NC}"
    echo "  Type to filter results"
    echo "  Use arrow keys to navigate results"
    echo "  Press Enter to select, Esc to cancel"
}

# show_dashboard_help() -> void
# Display dashboard-specific help
show_dashboard_help() {
    echo -e "${info_color:-$BLUE}Dashboard Help:${NC}"
    echo "  Press 'r' to refresh"
    echo "  Press 'q' to return to menu"
}

# =============================================================================
# Tips and Tricks
# =============================================================================

# show_random_tip() -> void
# Display a random helpful tip
show_random_tip() {
    local tips=(
        "Tip: Press '/' to quickly search for scripts"
        "Tip: Use 'd' to view system dashboard anytime"
        "Tip: Press '?' for comprehensive help"
        "Tip: Install fzf for enhanced search capabilities"
        "Tip: Configure custom themes in config.conf"
        "Tip: Add your own scripts to plugins/ directory"
        "Tip: Use 's' for quick system status check"
        "Tip: Press 'r' to refresh the menu"
        "Tip: Press 'F' to view your favorite scripts"
        "Tip: Use hooks to automate pre/post execution tasks"
        "Tip: Cache improves performance - enable in .bashmenu.env"
    )
    
    local random_index=$((RANDOM % ${#tips[@]}))
    echo -e "${CYAN}💡 ${tips[$random_index]}${NC}"
}

# =============================================================================
# Interactive Tutorial
# =============================================================================

# show_tutorial() -> void
# Display interactive tutorial
show_tutorial() {
    clear_screen
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                ${BOLD_CYAN:-$CYAN}BASHMENU TUTORIAL${NC}                          ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${BOLD_GREEN:-$GREEN}Welcome to Bashmenu!${NC}"
    echo ""
    echo "This tutorial will guide you through the main features."
    echo ""
    
    # Step 1: Navigation
    echo -e "${CYAN}Step 1: Navigation${NC}"
    echo "  • Use ↑/↓ arrow keys to move through menu items"
    echo "  • Press Enter to execute a script"
    echo "  • Press Home/End to jump to first/last item"
    echo ""
    read -p "Press Enter to continue..." -s
    echo ""
    
    # Step 2: Search
    echo -e "${CYAN}Step 2: Search${NC}"
    echo "  • Press '/' to open search mode"
    echo "  • Type to filter scripts by name, description, or tags"
    echo "  • Use ↑/↓ to navigate results"
    echo "  • Press Enter to select, Esc to cancel"
    echo ""
    read -p "Press Enter to continue..." -s
    echo ""
    
    # Step 3: Favorites
    echo -e "${CYAN}Step 3: Favorites${NC}"
    echo "  • Press 'F' to toggle favorite status on current script"
    echo "  • Press 'f' to view all favorites"
    echo "  • Favorites are saved in ~/.bashmenu/favorites.json"
    echo ""
    read -p "Press Enter to continue..." -s
    echo ""
    
    # Step 4: Commands
    echo -e "${CYAN}Step 4: Quick Commands${NC}"
    echo "  • Press 'd' for system dashboard"
    echo "  • Press 's' for quick status"
    echo "  • Press 'r' to refresh menu"
    echo "  • Press '?' for help anytime"
    echo "  • Press 'q' to quit"
    echo ""
    read -p "Press Enter to continue..." -s
    echo ""
    
    # Step 5: Configuration
    echo -e "${CYAN}Step 5: Configuration${NC}"
    echo "  • Edit ~/.bashmenu/.bashmenu.env for user settings"
    echo "  • Edit /opt/bashmenu/etc/.bashmenu.env for system settings"
    echo "  • Configure theme, cache, logging, and more"
    echo ""
    read -p "Press Enter to finish..." -s
    echo ""
    
    echo -e "${success_color:-$GREEN}Tutorial complete! Press any key to return...${NC}"
    read -s -n1
}

# =============================================================================
# Help Search
# =============================================================================

# help_search() -> void
# Search help topics
# Args:
#   $1 - Search query
help_search() {
    local query="$1"
    
    if [[ -z "$query" ]]; then
        echo "Usage: help_search <query>"
        return 1
    fi
    
    echo -e "${CYAN}Help topics matching '$query':${NC}"
    echo ""
    
    # Search in help content
    local found=false
    
    if [[ "$query" =~ search|find|filter ]]; then
        echo "  • Search: Press '/' to search scripts"
        echo "    Type to filter, use arrows to navigate"
        found=true
    fi
    
    if [[ "$query" =~ favorite|star|bookmark ]]; then
        echo "  • Favorites: Press 'F' to toggle favorite"
        echo "    Press 'f' to view all favorites"
        found=true
    fi
    
    if [[ "$query" =~ navigation|navigate|move ]]; then
        echo "  • Navigation: Use ↑/↓ arrows to move"
        echo "    Home/End to jump, Enter to select"
        found=true
    fi
    
    if [[ "$query" =~ config|settings|setup ]]; then
        echo "  • Configuration: Edit .bashmenu.env file"
        echo "    Location: ~/.bashmenu/.bashmenu.env"
        found=true
    fi
    
    if [[ "$query" =~ hook|event|trigger ]]; then
        echo "  • Hooks: Automate tasks with event hooks"
        echo "    Events: pre_execute, post_execute, on_error, on_load, on_exit"
        found=true
    fi
    
    if [[ "$found" == "false" ]]; then
        echo "  No help topics found for '$query'"
        echo "  Try: search, favorites, navigation, config, hooks"
    fi
    
    echo ""
}

# =============================================================================
# Tooltips
# =============================================================================

# show_tooltip() -> void
# Display tooltip for current context
# Args:
#   $1 - Tooltip key (script, menu, search, etc.)
show_tooltip() {
    local key="$1"
    
    case "$key" in
        script)
            echo -e "${info_color:-$BLUE}💡 Press Enter to execute, F to favorite${NC}"
            ;;
        menu)
            echo -e "${info_color:-$BLUE}💡 Use ↑↓ to navigate, / to search, ? for help${NC}"
            ;;
        search)
            echo -e "${info_color:-$BLUE}💡 Type to filter, Enter to select, Esc to cancel${NC}"
            ;;
        favorites)
            echo -e "${info_color:-$BLUE}💡 Your favorite scripts - Press F to toggle${NC}"
            ;;
        *)
            show_random_tip
            ;;
    esac
}

# =============================================================================
# Export Functions
# =============================================================================

export -f show_help_screen
export -f show_quick_help
export -f show_keyboard_shortcuts
export -f show_context_help
export -f show_random_tip
export -f show_tutorial
export -f help_search
export -f show_tooltip
