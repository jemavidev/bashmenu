#!/usr/bin/env bash
# Bashmenu v2.2 - Uninstall Script

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Installation paths
SYSTEM_INSTALL_DIR="/opt/bashmenu"
USER_INSTALL_DIR="$HOME/.local/bashmenu"
USER_DATA_DIR="$HOME/.bashmenu"
SYSTEM_LOG_DIR="/var/log/bashmenu"

#######################################
# Detect installation type
#######################################
detect_installation() {
    if [[ -d "$SYSTEM_INSTALL_DIR" ]]; then
        echo "system"
    elif [[ -d "$USER_INSTALL_DIR" ]]; then
        echo "user"
    else
        echo "none"
    fi
}

#######################################
# Uninstall system-wide
#######################################
uninstall_system() {
    echo -e "${CYAN}Uninstalling system-wide installation...${NC}"
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: System-wide uninstall requires root${NC}"
        echo "Run: sudo bash uninstall.sh"
        exit 1
    fi
    
    # Remove installation directory
    if [[ -d "$SYSTEM_INSTALL_DIR" ]]; then
        echo "Removing $SYSTEM_INSTALL_DIR..."
        rm -rf "$SYSTEM_INSTALL_DIR"
        echo -e "${GREEN}✓ Installation directory removed${NC}"
    fi
    
    # Remove logs
    if [[ -d "$SYSTEM_LOG_DIR" ]]; then
        echo "Removing $SYSTEM_LOG_DIR..."
        rm -rf "$SYSTEM_LOG_DIR"
        echo -e "${GREEN}✓ Log directory removed${NC}"
    fi
    
    # Remove symlink
    if [[ -L "/usr/local/bin/bashmenu" ]]; then
        echo "Removing symlink..."
        rm -f "/usr/local/bin/bashmenu"
        echo -e "${GREEN}✓ Symlink removed${NC}"
    fi
}

#######################################
# Uninstall user-level
#######################################
uninstall_user() {
    echo -e "${CYAN}Uninstalling user-level installation...${NC}"
    
    # Remove installation directory
    if [[ -d "$USER_INSTALL_DIR" ]]; then
        echo "Removing $USER_INSTALL_DIR..."
        rm -rf "$USER_INSTALL_DIR"
        echo -e "${GREEN}✓ Installation directory removed${NC}"
    fi
    
    # Remove symlink
    if [[ -L "$HOME/.local/bin/bashmenu" ]]; then
        echo "Removing symlink..."
        rm -f "$HOME/.local/bin/bashmenu"
        echo -e "${GREEN}✓ Symlink removed${NC}"
    fi
}

#######################################
# Remove user data
#######################################
remove_user_data() {
    local remove_data="$1"
    
    if [[ "$remove_data" == "yes" ]]; then
        echo -e "${CYAN}Removing user data...${NC}"
        
        if [[ -d "$USER_DATA_DIR" ]]; then
            echo "Removing $USER_DATA_DIR..."
            rm -rf "$USER_DATA_DIR"
            echo -e "${GREEN}✓ User data removed${NC}"
        fi
    else
        echo -e "${YELLOW}User data preserved in $USER_DATA_DIR${NC}"
        echo "To remove manually: rm -rf $USER_DATA_DIR"
    fi
}

#######################################
# Main
#######################################
main() {
    echo "========================================"
    echo "Bashmenu v2.2 - Uninstaller"
    echo "========================================"
    echo ""
    
    # Detect installation
    local install_type
    install_type=$(detect_installation)
    
    if [[ "$install_type" == "none" ]]; then
        echo -e "${YELLOW}No installation found${NC}"
        exit 0
    fi
    
    echo "Detected installation: $install_type"
    echo ""
    
    # Confirm uninstall
    read -p "Are you sure you want to uninstall Bashmenu? (yes/no): " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        echo "Uninstall cancelled"
        exit 0
    fi
    
    # Ask about user data
    echo ""
    read -p "Remove user data (~/.bashmenu)? (yes/no): " remove_data
    
    echo ""
    
    # Uninstall
    if [[ "$install_type" == "system" ]]; then
        uninstall_system
    else
        uninstall_user
    fi
    
    # Remove user data
    remove_user_data "$remove_data"
    
    echo ""
    echo "========================================"
    echo "Uninstall Complete"
    echo "========================================"
    echo ""
    echo -e "${GREEN}Bashmenu has been uninstalled${NC}"
    echo ""
    
    if [[ "$remove_data" != "yes" ]]; then
        echo "Your configuration and data are preserved in:"
        echo "  $USER_DATA_DIR"
        echo ""
    fi
}

main "$@"
