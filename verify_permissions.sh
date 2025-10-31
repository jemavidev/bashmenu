#!/bin/bash

# =============================================================================
# Automatic Verification Script for Permission System
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$PROJECT_DIR/config/config.conf"

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    Automatic Verification - Permission System         ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# Function to run test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "   [$TOTAL_TESTS] $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# =============================================================================
# File Tests
# =============================================================================
echo -e "${CYAN}[1] Verifying project files...${NC}"

run_test "Configuration file exists" "test -f '$CONFIG_FILE'"
run_test "main.sh file exists" "test -f '$PROJECT_DIR/src/main.sh'"
run_test "menu.sh file exists" "test -f '$PROJECT_DIR/src/menu.sh'"
run_test "commands.sh file exists" "test -f '$PROJECT_DIR/src/commands.sh'"
run_test "utils.sh file exists" "test -f '$PROJECT_DIR/src/utils.sh'"
run_test "bashmenu script exists" "test -f '$PROJECT_DIR/bashmenu'"
run_test "bashmenu script is executable" "test -x '$PROJECT_DIR/bashmenu'"

echo ""

# =============================================================================
# Configuration Tests
# =============================================================================
echo -e "${CYAN}[2] Verifying permission configuration...${NC}"

run_test "ENABLE_PERMISSIONS variable exists" "grep -q '^ENABLE_PERMISSIONS=' '$CONFIG_FILE'"
run_test "ADMIN_USERS variable exists" "grep -q '^ADMIN_USERS=' '$CONFIG_FILE'"
run_test "EXTERNAL_SCRIPTS variable exists" "grep -q '^EXTERNAL_SCRIPTS=' '$CONFIG_FILE'"

# Verify EXTERNAL_SCRIPTS format
if grep -A 10 "^EXTERNAL_SCRIPTS=" "$CONFIG_FILE" | grep -q "|"; then
    echo -e "   [$((TOTAL_TESTS + 1))] External scripts have correct format... ${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
else
    echo -e "   [$((TOTAL_TESTS + 1))] External scripts have correct format... ${RED}✗ FAIL${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
fi

echo ""

# =============================================================================
# Function Tests
# =============================================================================
echo -e "${CYAN}[3] Verifying permission system functions...${NC}"

# Source necessary files
source "$PROJECT_DIR/src/utils.sh" 2>/dev/null
source "$PROJECT_DIR/src/commands.sh" 2>/dev/null

run_test "get_user_level function exists" "declare -f get_user_level >/dev/null"
run_test "print_error function exists" "declare -f print_error >/dev/null"
run_test "print_success function exists" "declare -f print_success >/dev/null"

# Test get_user_level
if declare -f get_user_level >/dev/null; then
    USER_LEVEL=$(get_user_level)
    if [[ "$USER_LEVEL" =~ ^[1-3]$ ]]; then
        echo -e "   [$((TOTAL_TESTS + 1))] get_user_level returns valid value ($USER_LEVEL)... ${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "   [$((TOTAL_TESTS + 1))] get_user_level returns valid value... ${RED}✗ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
fi

echo ""

# =============================================================================
# Integration Tests
# =============================================================================
echo -e "${CYAN}[4] Verifying system integration...${NC}"

# Verify menu.sh uses ENABLE_PERMISSIONS
if grep -q "ENABLE_PERMISSIONS" "$PROJECT_DIR/src/menu.sh"; then
    echo -e "   [$((TOTAL_TESTS + 1))] menu.sh checks ENABLE_PERMISSIONS... ${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "   [$((TOTAL_TESTS + 1))] menu.sh checks ENABLE_PERMISSIONS... ${RED}✗ FAIL${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Verify menu.sh calls get_user_level
if grep -q "get_user_level" "$PROJECT_DIR/src/menu.sh"; then
    echo -e "   [$((TOTAL_TESTS + 1))] menu.sh calls get_user_level... ${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "   [$((TOTAL_TESTS + 1))] menu.sh calls get_user_level... ${RED}✗ FAIL${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Verify permission error messages exist
if grep -q "Access denied" "$PROJECT_DIR/src/menu.sh"; then
    echo -e "   [$((TOTAL_TESTS + 1))] Permission error messages exist... ${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "   [$((TOTAL_TESTS + 1))] Permission error messages exist... ${RED}✗ FAIL${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

echo ""

# =============================================================================
# Current System Status
# =============================================================================
echo -e "${CYAN}[5] Current system status...${NC}"

CURRENT_USER=$(whoami)
CURRENT_PERM=$(grep "^ENABLE_PERMISSIONS=" "$CONFIG_FILE" | cut -d'=' -f2)
ADMIN_USERS=$(grep "^ADMIN_USERS=" "$CONFIG_FILE" | cut -d'=' -f2)

echo -e "   Current user: ${YELLOW}$CURRENT_USER${NC}"
echo -e "   User level: ${YELLOW}$(get_user_level 2>/dev/null || echo "N/A")${NC}"
echo -e "   Permission system: ${YELLOW}$CURRENT_PERM${NC}"
echo -e "   Admin users: ${YELLOW}$ADMIN_USERS${NC}"

echo ""

# =============================================================================
# Test Summary
# =============================================================================
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    Test Summary                        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

PASS_RATE=$((TESTS_PASSED * 100 / TOTAL_TESTS))

echo -e "   Total tests: ${CYAN}$TOTAL_TESTS${NC}"
echo -e "   Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "   Tests failed: ${RED}$TESTS_FAILED${NC}"
echo -e "   Success rate: ${YELLOW}$PASS_RATE%${NC}"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓ ALL TESTS PASSED - SYSTEM IS FUNCTIONAL            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "   1. Run: ${YELLOW}./test_permissions.sh${NC}"
    echo -e "   2. Select option 1 to enable permissions"
    echo -e "   3. Run: ${YELLOW}./bashmenu${NC}"
    echo -e "   4. Verify you see 🔒 icons on blocked commands"
    echo ""
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ✗ SOME TESTS FAILED - REVIEW SYSTEM                  ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Review the errors above and verify:${NC}"
    echo -e "   • All files exist"
    echo -e "   • Configuration is correct"
    echo -e "   • Functions are defined"
    echo ""
    exit 1
fi
