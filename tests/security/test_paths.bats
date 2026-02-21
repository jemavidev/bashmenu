#!/usr/bin/env bats

# =============================================================================
# Security Tests for Path Validation
# =============================================================================

setup() {
    export PROJECT_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
}

@test "No hardcoded personal paths in config files" {
    # Check for /home/username patterns (excluding comments)
    run bash -c "grep -r '/home/[a-zA-Z0-9_]' '$PROJECT_ROOT/config' | grep -v '^#' | grep -v '\.example' || true"
    [ -z "$output" ]
}

@test "No hardcoded personal paths in source files" {
    # Check src/ for personal paths (excluding defaults and comments)
    run bash -c "grep -r '/home/[a-zA-Z0-9_]' '$PROJECT_ROOT/src' | grep -v 'BASHMENU_DEFAULTS' | grep -v '^#' || true"
    [ -z "$output" ]
}

@test "scripts.conf uses variables not absolute paths" {
    if [ -f "$PROJECT_ROOT/config/scripts.conf" ]; then
        # Should not have /home/ or /opt/ absolute paths (except in comments)
        run bash -c "grep -E '^\w+\|/home/|^\w+\|/opt/' '$PROJECT_ROOT/config/scripts.conf' | grep -v '^#' || true"
        [ -z "$output" ]
    fi
}

@test "config.conf uses environment variables" {
    if [ -f "$PROJECT_ROOT/config/config.conf" ]; then
        # Should use ${BASHMENU_*} variables
        run bash -c "grep 'BASHMENU_' '$PROJECT_ROOT/config/config.conf' | head -1"
        [ "$status" -eq 0 ]
    fi
}

@test ".bashmenu.env.example has no personal information" {
    if [ -f "$PROJECT_ROOT/.bashmenu.env.example" ]; then
        # Should not contain personal usernames
        run bash -c "grep -E '/home/(stk|rafael|user)' '$PROJECT_ROOT/.bashmenu.env.example' || true"
        [ -z "$output" ]
    fi
}

@test "Path validation script exists and works" {
    [ -f "$PROJECT_ROOT/scripts/validate-paths.sh" ]
    [ -x "$PROJECT_ROOT/scripts/validate-paths.sh" ]
    
    run bash "$PROJECT_ROOT/scripts/validate-paths.sh"
    [ "$status" -eq 0 ]
}

@test "No paths with spaces or special characters" {
    # Check for problematic path patterns
    run bash -c "grep -r 'BASHMENU.*=.*[[:space:]]' '$PROJECT_ROOT/config' | grep -v '^#' || true"
    [ -z "$output" ]
}

@test "All path variables use proper syntax" {
    # Check for ${VAR} not $VAR
    if [ -f "$PROJECT_ROOT/config/config.conf" ]; then
        run bash -c "grep '\$BASHMENU_' '$PROJECT_ROOT/config/config.conf' | grep -v '\${BASHMENU_' || true"
        [ -z "$output" ]
    fi
}
