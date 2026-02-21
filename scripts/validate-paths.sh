#!/bin/bash

# =============================================================================
# Path Validation Script
# =============================================================================
# Validates that no hardcoded personal paths exist in the codebase
# Returns 0 if validation passes, 1 if issues found
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=== Path Validation ==="
echo ""

# Track issues
issues_found=0

# Check for personal paths in config files
echo "Checking config files for hardcoded personal paths..."

# Pattern 1: /home/username paths (excluding examples and comments)
personal_paths=$(grep -r "/home/[a-zA-Z0-9_]" "$PROJECT_ROOT/config" 2>/dev/null | \
    grep -v "^#" | \
    grep -v "\.example" | \
    grep -v "# " || true)

if [[ -n "$personal_paths" ]]; then
    echo -e "${RED}✗ Found hardcoded personal paths in config files:${NC}"
    echo "$personal_paths"
    issues_found=$((issues_found + 1))
else
    echo -e "${GREEN}✓ No hardcoded personal paths in config files${NC}"
fi

# Check for absolute paths that should use variables
echo ""
echo "Checking for absolute paths that should use variables..."

# Check config.conf
if grep -q "^LOG_FILE=\"/tmp" "$PROJECT_ROOT/config/config.conf" 2>/dev/null; then
    echo -e "${YELLOW}⚠ LOG_FILE uses /tmp directly (should use \${BASHMENU_LOG_DIR})${NC}"
fi

if grep -q "^PLUGIN_DIR=\"/opt" "$PROJECT_ROOT/config/config.conf" 2>/dev/null; then
    echo -e "${YELLOW}⚠ PLUGIN_DIR uses /opt directly (should use \${BASHMENU_PLUGINS_DIR})${NC}"
fi

# Check scripts.conf.example
absolute_paths=$(grep -E "^\w+\|/opt/|^\w+\|/home/" "$PROJECT_ROOT/config/scripts.conf.example" 2>/dev/null | \
    grep -v "^#" || true)

if [[ -n "$absolute_paths" ]]; then
    echo -e "${RED}✗ Found absolute paths in scripts.conf.example:${NC}"
    echo "$absolute_paths"
    echo -e "${YELLOW}  Should use: \${BASHMENU_PLUGINS_DIR} or \${BASHMENU_SYSTEM_PLUGINS}${NC}"
    issues_found=$((issues_found + 1))
else
    echo -e "${GREEN}✓ scripts.conf.example uses variables correctly${NC}"
fi

# Check for hardcoded /opt/bashmenu in shell scripts (excluding defaults)
echo ""
echo "Checking shell scripts for hardcoded installation paths..."

hardcoded_opt=$(grep -r "/opt/bashmenu" "$PROJECT_ROOT/src" 2>/dev/null | \
    grep -v "BASHMENU_DEFAULTS" | \
    grep -v "# " | \
    grep -v "config_files" || true)

if [[ -n "$hardcoded_opt" ]]; then
    echo -e "${YELLOW}⚠ Found /opt/bashmenu references in src/ (check if they should use variables):${NC}"
    echo "$hardcoded_opt"
else
    echo -e "${GREEN}✓ No hardcoded /opt/bashmenu paths in src/${NC}"
fi

# Validate that config files use proper variable syntax
echo ""
echo "Validating variable usage in config files..."

# Check for proper ${VAR} syntax
if grep -q '\$BASHMENU_' "$PROJECT_ROOT/config/config.conf" 2>/dev/null; then
    improper_vars=$(grep '\$BASHMENU_' "$PROJECT_ROOT/config/config.conf" | \
        grep -v '\${BASHMENU_' || true)
    
    if [[ -n "$improper_vars" ]]; then
        echo -e "${YELLOW}⚠ Found variables without braces (should use \${VAR} not \$VAR):${NC}"
        echo "$improper_vars"
    else
        echo -e "${GREEN}✓ All variables use proper \${VAR} syntax${NC}"
    fi
fi

# Summary
echo ""
echo "=== Validation Summary ==="

if [[ $issues_found -eq 0 ]]; then
    echo -e "${GREEN}✓ All path validations passed${NC}"
    echo ""
    echo "Configuration uses:"
    echo "  • Environment variables from .bashmenu.env"
    echo "  • Proper \${VAR} syntax"
    echo "  • No hardcoded personal paths"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Found $issues_found issue(s)${NC}"
    echo ""
    echo "Please fix the issues above before proceeding."
    echo ""
    exit 1
fi
