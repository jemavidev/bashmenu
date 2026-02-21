#!/usr/bin/env bats

# =============================================================================
# Test Suite for Refactored Menu Modules
# =============================================================================
# Description: Unit tests for v3.0 refactored modules
# Version:     1.0
# =============================================================================

# Setup function - runs before each test
setup() {
    # Load test helpers
    load '../bats-testing/test/test_helper.bash'
    
    # Set up test environment
    export PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    export SCRIPT_DIR="$PROJECT_ROOT/src"
    
    # Source utilities first
    source "$SCRIPT_DIR/utils.sh"
    
    # Disable logging for tests
    export DEBUG_MODE=false
    export LOG_LEVEL=3
}

# =============================================================================
# Menu Core Tests
# =============================================================================

@test "menu_core.sh: module loads without errors" {
    run bash -n "$SCRIPT_DIR/menu_core.sh"
    [ "$status" -eq 0 ]
}

@test "menu_core.sh: initialize_menu function exists" {
    source "$SCRIPT_DIR/menu_core.sh"
    run declare -f initialize_menu
    [ "$status" -eq 0 ]
}

@test "menu_core.sh: add_menu_item function exists" {
    source "$SCRIPT_DIR/menu_core.sh"
    run declare -f add_menu_item
    [ "$status" -eq 0 ]
}

@test "menu_core.sh: add_menu_item adds item successfully" {
    source "$SCRIPT_DIR/menu_core.sh"
    
    # Initialize arrays
    menu_options=()
    menu_commands=()
    menu_descriptions=()
    menu_levels=()
    
    # Add item
    run add_menu_item "Test Item" "test_command" "Test Description" 1
    [ "$status" -eq 0 ]
    [ "${menu_options[0]}" = "Test Item" ]
    [ "${menu_commands[0]}" = "test_command" ]
}

@test "menu_core.sh: add_menu_item prevents duplicate commands" {
    source "$SCRIPT_DIR/menu_core.sh"
    
    # Initialize arrays
    menu_options=()
    menu_commands=()
    menu_descriptions=()
    menu_levels=()
    
    # Add first item
    add_menu_item "Test Item 1" "test_command" "Description 1" 1
    
    # Try to add duplicate
    run add_menu_item "Test Item 2" "test_command" "Description 2" 1
    [ "$status" -eq 1 ]
    [ "${#menu_options[@]}" -eq 1 ]
}

# =============================================================================
# Menu Themes Tests
# =============================================================================

@test "menu_themes.sh: module loads without errors" {
    run bash -n "$SCRIPT_DIR/menu_themes.sh"
    [ "$status" -eq 0 ]
}

@test "menu_themes.sh: initialize_themes function exists" {
    source "$SCRIPT_DIR/menu_themes.sh"
    run declare -f initialize_themes
    [ "$status" -eq 0 ]
}

@test "menu_themes.sh: load_theme function exists" {
    source "$SCRIPT_DIR/menu_themes.sh"
    run declare -f load_theme
    [ "$status" -eq 0 ]
}

@test "menu_themes.sh: initialize_themes creates theme variables" {
    source "$SCRIPT_DIR/menu_themes.sh"
    initialize_themes
    
    # Check default theme variables exist
    [ -n "$default_frame_top" ]
    [ -n "$default_title_color" ]
}

@test "menu_themes.sh: load_theme loads default theme" {
    source "$SCRIPT_DIR/menu_themes.sh"
    initialize_themes
    
    run load_theme "default"
    [ "$status" -eq 0 ]
    [ -n "$frame_top" ]
    [ -n "$title_color" ]
}

# =============================================================================
# Menu Display Tests
# =============================================================================

@test "menu_display.sh: module loads without errors" {
    run bash -n "$SCRIPT_DIR/menu_display.sh"
    [ "$status" -eq 0 ]
}

@test "menu_display.sh: clear_screen function exists" {
    source "$SCRIPT_DIR/menu_display.sh"
    run declare -f clear_screen
    [ "$status" -eq 0 ]
}

@test "menu_display.sh: display_header function exists" {
    source "$SCRIPT_DIR/menu_display.sh"
    run declare -f display_header
    [ "$status" -eq 0 ]
}

@test "menu_display.sh: display_menu function exists" {
    source "$SCRIPT_DIR/menu_display.sh"
    run declare -f display_menu
    [ "$status" -eq 0 ]
}

# =============================================================================
# Menu Input Tests
# =============================================================================

@test "menu_input.sh: module loads without errors" {
    run bash -n "$SCRIPT_DIR/menu_input.sh"
    [ "$status" -eq 0 ]
}

@test "menu_input.sh: handle_keyboard_input function exists" {
    source "$SCRIPT_DIR/menu_input.sh"
    run declare -f handle_keyboard_input
    [ "$status" -eq 0 ]
}

@test "menu_input.sh: handle_keyboard_input moves up correctly" {
    source "$SCRIPT_DIR/menu_input.sh"
    
    result=$(handle_keyboard_input "UP" 5 10)
    [ "$result" -eq 4 ]
}

@test "menu_input.sh: handle_keyboard_input moves down correctly" {
    source "$SCRIPT_DIR/menu_input.sh"
    
    result=$(handle_keyboard_input "DOWN" 5 10)
    [ "$result" -eq 6 ]
}

@test "menu_input.sh: handle_keyboard_input wraps at top" {
    source "$SCRIPT_DIR/menu_input.sh"
    
    result=$(handle_keyboard_input "UP" 0 10)
    [ "$result" -eq 9 ]
}

@test "menu_input.sh: handle_keyboard_input wraps at bottom" {
    source "$SCRIPT_DIR/menu_input.sh"
    
    result=$(handle_keyboard_input "DOWN" 9 10)
    [ "$result" -eq 0 ]
}

@test "menu_input.sh: validate_numeric_input accepts valid input" {
    source "$SCRIPT_DIR/menu_input.sh"
    
    run validate_numeric_input "5" 10
    [ "$status" -eq 0 ]
}

@test "menu_input.sh: validate_numeric_input rejects invalid input" {
    source "$SCRIPT_DIR/menu_input.sh"
    
    run validate_numeric_input "abc" 10
    [ "$status" -eq 1 ]
}

@test "menu_input.sh: validate_numeric_input rejects out of range" {
    source "$SCRIPT_DIR/menu_input.sh"
    
    run validate_numeric_input "15" 10
    [ "$status" -eq 1 ]
}

# =============================================================================
# Menu Validation Tests
# =============================================================================

@test "menu_validation.sh: module loads without errors" {
    run bash -n "$SCRIPT_DIR/menu_validation.sh"
    [ "$status" -eq 0 ]
}

@test "menu_validation.sh: sanitize_script_path function exists" {
    source "$SCRIPT_DIR/menu_validation.sh"
    run declare -f sanitize_script_path
    [ "$status" -eq 0 ]
}

@test "menu_validation.sh: sanitize_script_path removes directory traversal" {
    source "$SCRIPT_DIR/menu_validation.sh"
    
    result=$(sanitize_script_path "/path/../etc/passwd")
    [ "$result" = "" ]
}

@test "menu_validation.sh: sanitize_script_path accepts clean path" {
    source "$SCRIPT_DIR/menu_validation.sh"
    
    result=$(sanitize_script_path "/usr/local/bin/script.sh")
    [ "$result" = "/usr/local/bin/script.sh" ]
}

@test "menu_validation.sh: validate_absolute_path rejects relative paths" {
    source "$SCRIPT_DIR/menu_validation.sh"
    
    run validate_absolute_path "relative/path/script.sh"
    [ "$status" -eq 1 ]
}

@test "menu_validation.sh: validate_absolute_path accepts absolute paths" {
    source "$SCRIPT_DIR/menu_validation.sh"
    
    run validate_absolute_path "/absolute/path/script.sh"
    [ "$status" -eq 0 ]
}

# =============================================================================
# Menu Help Tests
# =============================================================================

@test "menu_help.sh: module loads without errors" {
    run bash -n "$SCRIPT_DIR/menu_help.sh"
    [ "$status" -eq 0 ]
}

@test "menu_help.sh: show_help_screen function exists" {
    source "$SCRIPT_DIR/menu_help.sh"
    run declare -f show_help_screen
    [ "$status" -eq 0 ]
}

@test "menu_help.sh: show_quick_help function exists" {
    source "$SCRIPT_DIR/menu_help.sh"
    run declare -f show_quick_help
    [ "$status" -eq 0 ]
}

# =============================================================================
# Menu Execution Tests
# =============================================================================

@test "menu_execution.sh: module loads without errors" {
    run bash -n "$SCRIPT_DIR/menu_execution.sh"
    [ "$status" -eq 0 ]
}

@test "menu_execution.sh: execute_menu_item function exists" {
    source "$SCRIPT_DIR/menu_execution.sh"
    run declare -f execute_menu_item
    [ "$status" -eq 0 ]
}

@test "menu_execution.sh: check_execution_permission function exists" {
    source "$SCRIPT_DIR/menu_execution.sh"
    run declare -f check_execution_permission
    [ "$status" -eq 0 ]
}

# =============================================================================
# Menu Loop Tests
# =============================================================================

@test "menu_loop.sh: module loads without errors" {
    run bash -n "$SCRIPT_DIR/menu_loop.sh"
    [ "$status" -eq 0 ]
}

@test "menu_loop.sh: menu_loop function exists" {
    source "$SCRIPT_DIR/menu_loop.sh"
    run declare -f menu_loop
    [ "$status" -eq 0 ]
}

@test "menu_loop.sh: menu_loop_classic function exists" {
    source "$SCRIPT_DIR/menu_loop.sh"
    run declare -f menu_loop_classic
    [ "$status" -eq 0 ]
}

@test "menu_loop.sh: menu_loop_hierarchical function exists" {
    source "$SCRIPT_DIR/menu_loop.sh"
    run declare -f menu_loop_hierarchical
    [ "$status" -eq 0 ]
}

# =============================================================================
# Menu Navigation Tests
# =============================================================================

@test "menu_navigation.sh: module loads without errors" {
    run bash -n "$SCRIPT_DIR/menu_navigation.sh"
    [ "$status" -eq 0 ]
}

@test "menu_navigation.sh: build_hierarchical_menu function exists" {
    source "$SCRIPT_DIR/menu_navigation.sh"
    run declare -f build_hierarchical_menu
    [ "$status" -eq 0 ]
}

@test "menu_navigation.sh: get_current_path_string function exists" {
    source "$SCRIPT_DIR/menu_navigation.sh"
    run declare -f get_current_path_string
    [ "$status" -eq 0 ]
}

@test "menu_navigation.sh: get_breadcrumb function exists" {
    source "$SCRIPT_DIR/menu_navigation.sh"
    run declare -f get_breadcrumb
    [ "$status" -eq 0 ]
}

# =============================================================================
# Integration Tests
# =============================================================================

@test "integration: all modules can be sourced together" {
    source "$SCRIPT_DIR/menu_core.sh"
    source "$SCRIPT_DIR/menu_themes.sh"
    source "$SCRIPT_DIR/menu_display.sh"
    source "$SCRIPT_DIR/menu_input.sh"
    source "$SCRIPT_DIR/menu_navigation.sh"
    source "$SCRIPT_DIR/menu_execution.sh"
    source "$SCRIPT_DIR/menu_loop.sh"
    source "$SCRIPT_DIR/menu_validation.sh"
    source "$SCRIPT_DIR/menu_help.sh"
    
    # Verify no conflicts
    run declare -f initialize_menu
    [ "$status" -eq 0 ]
}

@test "integration: menu_refactored.sh loads all modules" {
    run bash -n "$SCRIPT_DIR/menu_refactored.sh"
    [ "$status" -eq 0 ]
}
