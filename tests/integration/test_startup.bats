#!/usr/bin/env bats

# =============================================================================
# Integration Tests for System Startup
# =============================================================================

setup() {
    export PROJECT_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    export SCRIPT_DIR="$PROJECT_ROOT/src"
}

@test "main.sh exists and is executable" {
    [ -f "$SCRIPT_DIR/main.sh" ]
    [ -x "$SCRIPT_DIR/main.sh" ]
}

@test "main.sh has correct version" {
    run bash -c "grep 'readonly SCRIPT_VERSION=' '$SCRIPT_DIR/main.sh' | cut -d'\"' -f2"
    [ "$output" = "2.2" ]
}

@test "main.sh syntax is valid" {
    run bash -n "$SCRIPT_DIR/main.sh"
    [ "$status" -eq 0 ]
}

@test "config module exists" {
    [ -f "$SCRIPT_DIR/core/config.sh" ]
}

@test "config module syntax is valid" {
    run bash -n "$SCRIPT_DIR/core/config.sh"
    [ "$status" -eq 0 ]
}

@test "menu_refactored module exists" {
    [ -f "$SCRIPT_DIR/menu_refactored.sh" ]
}

@test "menu_refactored syntax is valid" {
    run bash -n "$SCRIPT_DIR/menu_refactored.sh"
    [ "$status" -eq 0 ]
}

@test "all core modules exist" {
    [ -f "$SCRIPT_DIR/core/utils.sh" ]
    [ -f "$SCRIPT_DIR/core/config.sh" ]
    [ -f "$SCRIPT_DIR/core/commands.sh" ]
}

@test "all menu modules exist" {
    [ -f "$SCRIPT_DIR/menu/core.sh" ]
    [ -f "$SCRIPT_DIR/menu/display.sh" ]
    [ -f "$SCRIPT_DIR/menu/input.sh" ]
}

@test "PROJECT_ROOT is exported in main.sh" {
    run bash -c "grep 'export PROJECT_ROOT' '$SCRIPT_DIR/main.sh'"
    [ "$status" -eq 0 ]
}

@test "INSTALL_TYPE detection exists" {
    run bash -c "grep 'readonly INSTALL_TYPE=' '$SCRIPT_DIR/main.sh'"
    [ "$status" -eq 0 ]
}

@test "validate_installation function exists" {
    run bash -c "grep 'validate_installation()' '$SCRIPT_DIR/main.sh'"
    [ "$status" -eq 0 ]
}

@test "config module loaded before logger" {
    # Config should appear before logger in load order
    config_line=$(grep -n "Load config module" "$SCRIPT_DIR/main.sh" | cut -d: -f1)
    logger_line=$(grep -n "Load logger" "$SCRIPT_DIR/main.sh" | cut -d: -f1)
    
    [ "$config_line" -lt "$logger_line" ]
}

@test "main.sh --version works" {
    run bash "$SCRIPT_DIR/main.sh" --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "2.2" ]]
}

@test "main.sh --help works" {
    run bash "$SCRIPT_DIR/main.sh" --help
    [ "$status" -eq 0 ]
}

@test ".bashmenu.env.example exists" {
    [ -f "$PROJECT_ROOT/.bashmenu.env.example" ]
}

@test "Makefile exists with required targets" {
    [ -f "$PROJECT_ROOT/Makefile" ]
    run bash -c "grep -E '^(setup|test|lint):' '$PROJECT_ROOT/Makefile'"
    [ "$status" -eq 0 ]
}
