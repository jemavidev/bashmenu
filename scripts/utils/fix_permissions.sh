#!/bin/bash

# =============================================================================
# Fix Permissions Script - Bashmenu
# =============================================================================
# Description: Fix execution permissions for all Bashmenu scripts
# Version:     1.0
# Author:      JESUS MARIA VILLALOBOS
# =============================================================================

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}              Bashmenu - Fix Permissions Script                    ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${YELLOW}Fixing permissions...${NC}"
echo ""

# Fix main scripts
echo "📁 Main scripts:"
chmod +x "$SCRIPT_DIR/bashmenu" 2>/dev/null && echo -e "  ${GREEN}✓${NC} bashmenu" || echo -e "  ${YELLOW}⚠${NC} bashmenu (already executable or not found)"
chmod +x "$SCRIPT_DIR/migrate_to_v3.sh" 2>/dev/null && echo -e "  ${GREEN}✓${NC} migrate_to_v3.sh" || echo -e "  ${YELLOW}⚠${NC} migrate_to_v3.sh (already executable or not found)"
chmod +x "$SCRIPT_DIR/install.sh" 2>/dev/null && echo -e "  ${GREEN}✓${NC} install.sh" || echo -e "  ${YELLOW}⚠${NC} install.sh (already executable or not found)"

echo ""
echo "📁 Source files (src/):"
if [[ -d "$SCRIPT_DIR/src" ]]; then
    chmod +x "$SCRIPT_DIR/src"/*.sh 2>/dev/null
    count=$(ls -1 "$SCRIPT_DIR/src"/*.sh 2>/dev/null | wc -l)
    echo -e "  ${GREEN}✓${NC} Fixed $count files in src/"
else
    echo -e "  ${YELLOW}⚠${NC} src/ directory not found"
fi

echo ""
echo "📁 Plugin scripts:"
if [[ -d "$SCRIPT_DIR/plugins" ]]; then
    # Fix all .sh files in plugins recursively
    find "$SCRIPT_DIR/plugins" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null
    count=$(find "$SCRIPT_DIR/plugins" -type f -name "*.sh" 2>/dev/null | wc -l)
    echo -e "  ${GREEN}✓${NC} Fixed $count files in plugins/"
else
    echo -e "  ${YELLOW}⚠${NC} plugins/ directory not found"
fi

echo ""
echo "📁 Test scripts:"
if [[ -d "$SCRIPT_DIR/tests" ]]; then
    chmod +x "$SCRIPT_DIR/tests"/*.bats 2>/dev/null
    count=$(ls -1 "$SCRIPT_DIR/tests"/*.bats 2>/dev/null | wc -l)
    echo -e "  ${GREEN}✓${NC} Fixed $count test files"
else
    echo -e "  ${YELLOW}⚠${NC} tests/ directory not found"
fi

echo ""
echo "📁 AgentX scripts:"
if [[ -d "$SCRIPT_DIR/AgentX/.agent-configs/scripts" ]]; then
    chmod +x "$SCRIPT_DIR/AgentX/.agent-configs/scripts"/*.sh 2>/dev/null
    count=$(ls -1 "$SCRIPT_DIR/AgentX/.agent-configs/scripts"/*.sh 2>/dev/null | wc -l)
    echo -e "  ${GREEN}✓${NC} Fixed $count AgentX scripts"
else
    echo -e "  ${YELLOW}⚠${NC} AgentX scripts directory not found"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                  Permissions Fixed Successfully!                  ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "You can now run:"
echo "  ./bashmenu"
echo ""
