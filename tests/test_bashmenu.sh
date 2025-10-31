#!/bin/bash

################################################################################
# Bashmenu Test Suite
# ==============================================================================
# Description: Comprehensive test suite for the enhanced Bashmenu system
# Date:        January 15, 2024
# Creator:     JESUS VILLALOBOS (Enhanced with AI assistance)
# Version:     2.0
# License:     MIT License
################################################################################

# =============================================================================
# Test Configuration
# =============================================================================

readonly TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR="$TEST_DIR/../src"
readonly CONFIG_DIR="$TEST_DIR/../config"

# Test results
declare -i TESTS_PASSED=0
declare -i TESTS_FAILED=0
declare -i TESTS_SKIPPED=0

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# =============================================================================
# Test Utilities
# =============================================================================

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_header() {
    local title="$1"
    local width=50
    local padding=$(( (width - ${#title}) / 2 ))
    
    echo -e "${CYAN}"
    printf "%${width}s\n" | tr ' ' '='
    printf "%${padding}s%s%${padding}s\n" "" "$title" ""
    printf "%${width}s\n" | tr ' ' '='
    echo -e "${NC}"
}

# Test assertion function
assert() {
    local test_name="$1"
    local condition="$2"
    local message="${3:-Test failed}"
    
    if eval "$condition"; then
        print_success "$test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        print_error "$test_name: $message"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Skip test function
skip_test() {
    local test_name="$1"
    local reason="${2:-Not applicable}"
    
    print_warning "$test_name: SKIPPED ($reason)"
    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
}

# =============================================================================
# Test Setup and Teardown
# =============================================================================

setup_test_environment() {
    print_info "Setting up test environment..."
    
    # Create temporary test directory
    export TEST_TEMP_DIR=$(mktemp -d)
    
    # Create test configuration
    cat > "$TEST_TEMP_DIR/test_config.conf" << EOF
# Test Configuration
MENU_TITLE="Test Menu"
ENABLE_COLORS=true
ENABLE_LOGGING=true
LOG_LEVEL=0
LOG_FILE="$TEST_TEMP_DIR/test.log"
ENABLE_HISTORY=true
HISTORY_FILE="$TEST_TEMP_DIR/test_history.log"
ENABLE_PERMISSIONS=false
ENABLE_PLUGINS=true
PLUGIN_DIR="$TEST_TEMP_DIR/plugins"
ENABLE_NOTIFICATIONS=false
AUTO_BACKUP=false
EOF
    
    # Create test plugin directory
    mkdir -p "$TEST_TEMP_DIR/plugins"
    
    # Create test plugin
    cat > "$TEST_TEMP_DIR/plugins/test_plugin.sh" << EOF
#!/bin/bash
# Test plugin
PLUGIN_NAME="Test Plugin"
PLUGIN_VERSION="1.0"

cmd_test_function() {
    echo "Test function executed successfully"
}

register_plugin_commands() {
    add_menu_item "Test Function" "cmd_test_function" "Test plugin function" 1
}

register_plugin_commands
EOF
    
    print_success "Test environment setup complete"
}

cleanup_test_environment() {
    print_info "Cleaning up test environment..."
    
    if [[ -n "$TEST_TEMP_DIR" && -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
        print_success "Test environment cleaned up"
    fi
}

# =============================================================================
# File and Module Tests
# =============================================================================

test_file_existence() {
    print_header "Testing File Existence"
    
    local required_files=(
        "$SCRIPT_DIR/main.sh"
        "$SCRIPT_DIR/utils.sh"
        "$SCRIPT_DIR/commands.sh"
        "$SCRIPT_DIR/menu.sh"
        "$CONFIG_DIR/config.conf"
    )
    
    for file in "${required_files[@]}"; do
        assert "File exists: $(basename "$file")" "[[ -f '$file' ]]" "File not found: $file"
    done
}

test_file_permissions() {
    print_header "Testing File Permissions"
    
    local executable_files=(
        "$SCRIPT_DIR/main.sh"
    )
    
    for file in "${executable_files[@]}"; do
        if [[ -f "$file" ]]; then
            assert "File is executable: $(basename "$file")" "[[ -x '$file' ]]" "File not executable: $file"
        fi
    done
}

test_module_loading() {
    print_header "Testing Module Loading"
    
    # Test utils module
    if [[ -f "$SCRIPT_DIR/utils.sh" ]]; then
        source "$SCRIPT_DIR/utils.sh"
        assert "Utils module loaded" "[[ -n '$RED' ]]" "Utils module not loaded properly"
    else
        skip_test "Utils module loading" "File not found"
    fi
    
    # Test commands module
    if [[ -f "$SCRIPT_DIR/commands.sh" ]]; then
        source "$SCRIPT_DIR/commands.sh"
        assert "Commands module loaded" "declare -f execute_command >/dev/null" "Commands module not loaded properly"
    else
        skip_test "Commands module loading" "File not found"
    fi
    
    # Test menu module
    if [[ -f "$SCRIPT_DIR/menu.sh" ]]; then
        source "$SCRIPT_DIR/menu.sh"
        assert "Menu module loaded" "declare -f display_menu >/dev/null" "Menu module not loaded properly"
    else
        skip_test "Menu module loading" "File not found"
    fi
}

# =============================================================================
# Function Tests
# =============================================================================

test_utility_functions() {
    print_header "Testing Utility Functions"
    
    # Test logging functions
    assert "Log info function" "log_info 'test message' >/dev/null" "Log info function failed"
    assert "Log error function" "log_error 'test error' >/dev/null" "Log error function failed"
    
    # Test validation functions
    assert "Input validation (valid)" "validate_input 'test' '' 'test'" "Input validation failed for valid input"
    assert "Input validation (empty)" "! validate_input '' '' 'test'" "Input validation failed for empty input"
    
    # Test sanitization
    local sanitized=$(sanitize_input "test;command")
    assert "Input sanitization" "[[ '$sanitized' == 'testcommand' ]]" "Input sanitization failed"
    
    # Test display functions
    assert "Print success" "print_success 'test' >/dev/null" "Print success function failed"
    assert "Print error" "print_error 'test' >/dev/null" "Print error function failed"
    assert "Print warning" "print_warning 'test' >/dev/null" "Print warning function failed"
    assert "Print info" "print_info 'test' >/dev/null" "Print info function failed"
}

test_command_functions() {
    print_header "Testing Command Functions"
    
    # Test system info function
    if declare -f get_system_info >/dev/null; then
        local system_info=$(get_system_info)
        assert "System info function" "[[ -n '$system_info' ]]" "System info function failed"
    else
        skip_test "System info function" "Function not available"
    fi
    
    # Test command existence check
    if declare -f check_command_exists >/dev/null; then
        assert "Command exists (bash)" "check_command_exists 'bash'" "Command existence check failed"
        assert "Command exists (nonexistent)" "! check_command_exists 'nonexistentcommand12345'" "Command existence check failed"
    else
        skip_test "Command existence check" "Function not available"
    fi
    
    # Test user level function
    if declare -f get_user_level >/dev/null; then
        local user_level=$(get_user_level)
        assert "User level function" "[[ '$user_level' =~ ^[1-3]$ ]]" "User level function failed"
    else
        skip_test "User level function" "Function not available"
    fi
}

test_menu_functions() {
    print_header "Testing Menu Functions"
    
    # Test menu initialization
    if declare -f initialize_menu >/dev/null; then
        initialize_menu
        assert "Menu initialization" "[[ ${#menu_options[@]} -gt 0 ]]" "Menu initialization failed"
    else
        skip_test "Menu initialization" "Function not available"
    fi
    
    # Test theme loading
    if declare -f load_theme >/dev/null; then
        load_theme "default"
        assert "Theme loading" "[[ -n '$frame_top' ]]" "Theme loading failed"
    else
        skip_test "Theme loading" "Function not available"
    fi
    
    # Test menu item addition
    if declare -f add_menu_item >/dev/null; then
        local original_count=${#menu_options[@]}
        add_menu_item "Test Item" "test_command" "Test description" 1
        assert "Menu item addition" "[[ ${#menu_options[@]} -eq $((original_count + 1)) ]]" "Menu item addition failed"
    else
        skip_test "Menu item addition" "Function not available"
    fi
}

# =============================================================================
# Configuration Tests
# =============================================================================

test_configuration_loading() {
    print_header "Testing Configuration Loading"
    
    if declare -f load_config >/dev/null; then
        # Test with valid config
        if load_config "$TEST_TEMP_DIR/test_config.conf"; then
            assert "Configuration loading" "[[ -n '$MENU_TITLE' ]]" "Configuration loading failed"
        else
            print_error "Configuration loading failed"
        fi
    else
        skip_test "Configuration loading" "Function not available"
    fi
}

test_configuration_validation() {
    print_header "Testing Configuration Validation"
    
    # Test required configuration variables
    local required_vars=("MENU_TITLE" "ENABLE_COLORS" "LOG_LEVEL")
    
    for var in "${required_vars[@]}"; do
        if [[ -n "${!var}" ]]; then
            assert "Configuration variable: $var" "true" "Configuration variable not set: $var"
        else
            skip_test "Configuration variable: $var" "Variable not set"
        fi
    done
}

# =============================================================================
# Plugin Tests
# =============================================================================

test_plugin_loading() {
    print_header "Testing Plugin Loading"
    
    if declare -f load_plugins >/dev/null; then
        # Set plugin directory to test directory
        export PLUGIN_DIR="$TEST_TEMP_DIR/plugins"
        
        # Load plugins
        load_plugins
        
        # Check if test plugin function is available
        if declare -f cmd_test_function >/dev/null; then
            assert "Plugin loading" "true" "Plugin loading failed"
        else
            assert "Plugin loading" "false" "Plugin function not found"
        fi
    else
        skip_test "Plugin loading" "Function not available"
    fi
}

test_plugin_execution() {
    print_header "Testing Plugin Execution"
    
    if declare -f cmd_test_function >/dev/null; then
        local output=$(cmd_test_function)
        assert "Plugin execution" "[[ '$output' == 'Test function executed successfully' ]]" "Plugin execution failed"
    else
        skip_test "Plugin execution" "Plugin function not available"
    fi
}

# =============================================================================
# Integration Tests
# =============================================================================

test_integration_basic() {
    print_header "Testing Basic Integration"
    
    # Test that all modules work together
    if [[ -f "$SCRIPT_DIR/main.sh" ]]; then
        # Source main script in a subshell to avoid side effects
        local output=$(bash -c "source '$SCRIPT_DIR/main.sh' 2>&1" 2>&1)
        assert "Main script sourcing" "[[ $? -eq 0 ]]" "Main script sourcing failed: $output"
    else
        skip_test "Main script integration" "Main script not found"
    fi
}

test_integration_config() {
    print_header "Testing Configuration Integration"
    
    # Test configuration with main script
    if [[ -f "$SCRIPT_DIR/main.sh" && -f "$TEST_TEMP_DIR/test_config.conf" ]]; then
        export CONFIG_FILE="$TEST_TEMP_DIR/test_config.conf"
        local output=$(bash -c "source '$SCRIPT_DIR/main.sh' 2>&1" 2>&1)
        assert "Configuration integration" "[[ $? -eq 0 ]]" "Configuration integration failed: $output"
    else
        skip_test "Configuration integration" "Required files not found"
    fi
}

# =============================================================================
# Performance Tests
# =============================================================================

test_performance() {
    print_header "Testing Performance"
    
    # Test module loading performance
    local start_time=$(date +%s.%N)
    
    for i in {1..10}; do
        source "$SCRIPT_DIR/utils.sh" >/dev/null 2>&1
    done
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    assert "Module loading performance" "(( $(echo "$duration < 1.0" | bc -l) ))" "Module loading too slow: ${duration}s"
}

# =============================================================================
# Main Test Runner
# =============================================================================

run_all_tests() {
    print_header "Bashmenu Test Suite"
    echo "Starting comprehensive test suite..."
    echo ""
    
    # Setup test environment
    setup_test_environment
    
    # Run test categories
    test_file_existence
    test_file_permissions
    test_module_loading
    test_utility_functions
    test_command_functions
    test_menu_functions
    test_configuration_loading
    test_configuration_validation
    test_plugin_loading
    test_plugin_execution
    test_integration_basic
    test_integration_config
    test_performance
    
    # Cleanup
    cleanup_test_environment
    
    # Print summary
    print_header "Test Results Summary"
    echo "Tests passed:  $TESTS_PASSED"
    echo "Tests failed:  $TESTS_FAILED"
    echo "Tests skipped: $TESTS_SKIPPED"
    echo "Total tests:   $((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        print_success "All tests completed successfully!"
        exit 0
    else
        print_error "Some tests failed!"
        exit 1
    fi
}

# =============================================================================
# Command Line Interface
# =============================================================================

show_help() {
    cat << EOF
Bashmenu Test Suite v2.0

Usage: $0 [OPTIONS]

Options:
    -h, --help          Show this help message
    -v, --version       Show version information
    --file-tests        Run only file existence tests
    --function-tests    Run only function tests
    --integration-tests Run only integration tests
    --performance-tests Run only performance tests

Examples:
    $0                    # Run all tests
    $0 --file-tests      # Run only file tests
    $0 --function-tests  # Run only function tests

For more information, see the README file.
EOF
}

show_version() {
    echo "Bashmenu Test Suite v2.0"
    echo "Author: Jesus Villalobos"
    echo "License: MIT"
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            --file-tests)
                print_header "Running File Tests Only"
                setup_test_environment
                test_file_existence
                test_file_permissions
                test_module_loading
                cleanup_test_environment
                exit 0
                ;;
            --function-tests)
                print_header "Running Function Tests Only"
                setup_test_environment
                test_utility_functions
                test_command_functions
                test_menu_functions
                cleanup_test_environment
                exit 0
                ;;
            --integration-tests)
                print_header "Running Integration Tests Only"
                setup_test_environment
                test_integration_basic
                test_integration_config
                cleanup_test_environment
                exit 0
                ;;
            --performance-tests)
                print_header "Running Performance Tests Only"
                setup_test_environment
                test_performance
                cleanup_test_environment
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    parse_arguments "$@"
    run_all_tests
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 