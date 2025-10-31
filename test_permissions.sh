#!/bin/bash

# =============================================================================
# Bashmenu Permission System Test Script
# =============================================================================
# This script will help you implement and verify the permission system
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$PROJECT_DIR/config/config.conf"

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    Permission System Test - Bashmenu v2.0             ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# =============================================================================
# Step 1: Verify current user
# =============================================================================
echo -e "${CYAN}[Step 1] Verifying current user...${NC}"
CURRENT_USER=$(whoami)
echo -e "   Current user: ${YELLOW}$CURRENT_USER${NC}"

# Determine user level
if [[ "$CURRENT_USER" == "root" ]]; then
    USER_LEVEL=3
    echo -e "   Permission level: ${GREEN}3 (Root/Superuser)${NC}"
elif [[ "$CURRENT_USER" == "admin" ]]; then
    USER_LEVEL=2
    echo -e "   Permission level: ${YELLOW}2 (Administrator)${NC}"
else
    USER_LEVEL=1
    echo -e "   Permission level: ${YELLOW}1 (Basic user)${NC}"
fi
echo ""

# =============================================================================
# Step 2: Show current configuration
# =============================================================================
echo -e "${CYAN}[Step 2] Current permission configuration...${NC}"
if [[ -f "$CONFIG_FILE" ]]; then
    CURRENT_PERM=$(grep "^ENABLE_PERMISSIONS=" "$CONFIG_FILE" | cut -d'=' -f2)
    echo -e "   Current status: ${YELLOW}$CURRENT_PERM${NC}"
    
    ADMIN_USERS=$(grep "^ADMIN_USERS=" "$CONFIG_FILE" | cut -d'=' -f2)
    echo -e "   Admin users: ${YELLOW}$ADMIN_USERS${NC}"
else
    echo -e "   ${RED}✗ Configuration file not found${NC}"
    exit 1
fi
echo ""

# =============================================================================
# Step 3: Test options
# =============================================================================
echo -e "${CYAN}[Step 3] Available test options:${NC}"
echo ""
echo "   1. Enable permission system"
echo "   2. Disable permission system"
echo "   3. Add current user as admin"
echo "   4. Test permissions with demo menu"
echo "   5. View detailed status"
echo "   6. Exit"
echo ""

read -p "Select an option (1-6): " option

case $option in
    1)
        echo ""
        echo -e "${CYAN}[Action] Enabling permission system...${NC}"
        sed -i 's/^ENABLE_PERMISSIONS=.*/ENABLE_PERMISSIONS=true/' "$CONFIG_FILE"
        echo -e "${GREEN}✓ Permission system enabled${NC}"
        echo -e "${YELLOW}⚠ Restart bashmenu to apply changes${NC}"
        ;;
    2)
        echo ""
        echo -e "${CYAN}[Action] Disabling permission system...${NC}"
        sed -i 's/^ENABLE_PERMISSIONS=.*/ENABLE_PERMISSIONS=false/' "$CONFIG_FILE"
        echo -e "${GREEN}✓ Permission system disabled${NC}"
        echo -e "${YELLOW}⚠ Restart bashmenu to apply changes${NC}"
        ;;
    3)
        echo ""
        echo -e "${CYAN}[Action] Adding $CURRENT_USER as administrator...${NC}"
        
        # Read current users
        CURRENT_ADMINS=$(grep "^ADMIN_USERS=" "$CONFIG_FILE" | sed 's/ADMIN_USERS=(\(.*\))/\1/' | tr -d '"')
        
        # Check if already in list
        if echo "$CURRENT_ADMINS" | grep -q "$CURRENT_USER"; then
            echo -e "${YELLOW}⚠ $CURRENT_USER is already in the administrator list${NC}"
        else
            # Add user
            NEW_ADMINS="ADMIN_USERS=(\"root\" \"admin\" \"$CURRENT_USER\")"
            sed -i "s/^ADMIN_USERS=.*/$NEW_ADMINS/" "$CONFIG_FILE"
            echo -e "${GREEN}✓ User $CURRENT_USER added as administrator${NC}"
            echo -e "${YELLOW}⚠ Note: This only affects configuration, not the actual user level${NC}"
        fi
        ;;
    4)
        echo ""
        echo -e "${CYAN}[Action] Starting demo menu...${NC}"
        echo ""
        
        # Create temporary test script
        cat > /tmp/test_menu_permissions.sh << 'EOFMENU'
#!/bin/bash

# Load configuration
source "$(dirname "$0")/config/config.conf"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to get user level
get_user_level() {
    if [[ "$(whoami)" == "root" ]]; then
        echo "3"
    elif [[ "$(whoami)" == "admin" ]]; then
        echo "2"
    else
        echo "1"
    fi
}

# Test menu
clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         Demo Menu - Permission System                 ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

USER_LEVEL=$(get_user_level)
echo -e "User: ${YELLOW}$(whoami)${NC} | Level: ${YELLOW}$USER_LEVEL${NC}"
echo -e "Permission system: ${YELLOW}${ENABLE_PERMISSIONS:-false}${NC}"
echo ""
echo -e "${CYAN}Menu options:${NC}"
echo ""

# Define options with their required levels
declare -a options=(
    "View system information|1"
    "Run database backup|2"
    "Update entire system|3"
    "Restart services|2"
    "Modify network configuration|3"
)

# Display options
for i in "${!options[@]}"; do
    IFS='|' read -r name level <<< "${options[$i]}"
    
    # Check permissions
    can_execute=true
    icon="  "
    
    if [[ "${ENABLE_PERMISSIONS:-false}" == "true" ]]; then
        if [[ $USER_LEVEL -lt $level ]]; then
            can_execute=false
            icon="🔒"
        else
            icon="✓ "
        fi
    else
        icon="✓ "
    fi
    
    # Display option
    if [[ "$can_execute" == "true" ]]; then
        echo -e "   $icon $((i+1)). ${GREEN}$name${NC} (Level $level)"
    else
        echo -e "   $icon $((i+1)). ${RED}$name${NC} (Level $level - Requires level $level)"
    fi
done

echo ""
echo -e "${CYAN}Legend:${NC}"
echo -e "   ✓  = You can execute this command"
echo -e "   🔒 = Blocked (requires higher permission level)"
echo ""
echo -e "${YELLOW}Press Enter to continue...${NC}"
read
EOFMENU

        chmod +x /tmp/test_menu_permissions.sh
        bash /tmp/test_menu_permissions.sh
        rm /tmp/test_menu_permissions.sh
        ;;
    5)
        echo ""
        echo -e "${CYAN}[Detailed Status]${NC}"
        echo ""
        echo -e "${CYAN}═══ User Information ═══${NC}"
        echo -e "   Current user: ${YELLOW}$CURRENT_USER${NC}"
        echo -e "   Permission level: ${YELLOW}$USER_LEVEL${NC}"
        echo -e "   UID: ${YELLOW}$(id -u)${NC}"
        echo -e "   GID: ${YELLOW}$(id -g)${NC}"
        echo ""
        
        echo -e "${CYAN}═══ Permission Configuration ═══${NC}"
        grep -E "^ENABLE_PERMISSIONS=|^ADMIN_USERS=" "$CONFIG_FILE" | while read line; do
            echo -e "   ${YELLOW}$line${NC}"
        done
        echo ""
        
        echo -e "${CYAN}═══ Configured External Scripts ═══${NC}"
        grep -A 10 "^EXTERNAL_SCRIPTS=" "$CONFIG_FILE" | grep "|" | while IFS='|' read name path desc level; do
            if [[ -n "$name" ]]; then
                echo -e "   ${YELLOW}$name${NC} - Required level: ${YELLOW}$level${NC}"
            fi
        done
        echo ""
        ;;
    6)
        echo ""
        echo -e "${GREEN}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo ""
        echo -e "${RED}✗ Invalid option${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Operation completed${NC}"
echo ""
