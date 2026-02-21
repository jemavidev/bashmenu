#!/usr/bin/env bats

# =============================================================================
# Unit Tests for src/core/config.sh
# =============================================================================

# Setup function - runs before each test
setup() {
    # Load the module to test
    source "$BATS_TEST_DIRNAME/../../../src/core/config.sh"
    
    # Create temporary test directory
    export TEST_DIR="$BATS_TEST_TMPDIR/bashmenu_test_$$"
    mkdir -p "$TEST_DIR"
    
    # Create temporary .env file for testing
    export TEST_ENV_FILE="$TEST_DIR/.bashmenu.env"
}

# Teardown function - runs after each test
teardown() {
    # Clean up test directory
    rm -rf "$TEST_DIR"
    
    # Unset test environment variables
    unset TEST_DIR
    unset TEST_ENV_FILE
    unset BASHMENU_TEST_VAR
    unset BASHMENU_HOME
    unset BASHMENU_THEME
}

# =============================================================================
# Tests for load_env_file()
# =============================================================================

@test "load_env_file: returns 1 when file does not exist" {
    run load_env_file "/nonexistent/file.env"
    [ "$status" -eq 1 ]
}

@test "load_env_file: loads simple key=value pairs" {
    cat > "$TEST_ENV_FILE" << 'EOF'
BASHMENU_TEST_VAR=test_value
BASHMENU_HOME=/opt/bashmenu
EOF
    
    run load_env_file "$TEST_ENV_FILE"
    [ "$status" -eq 0 ]
    [ "$BASHMENU_TEST_VAR" = "test_value" ]
    [ "$BASHMENU_HOME" = "/opt/bashmenu" ]
}

@test "load_env_file: skips comments" {
    cat > "$TEST_ENV_FILE" << 'EOF'
# This is a comment
BASHMENU_TEST_VAR=value1
# Another comment
BASHMENU_HOME=/opt/bashmenu
EOF
    
    run load_env_file "$TEST_ENV_FILE"
    [ "$status" -eq 0 ]
    [ "$BASHMENU_TEST_VAR" = "value1" ]
}

@test "load_env_file: skips empty lines" {
    cat > "$TEST_ENV_FILE" << 'EOF'
BASHMENU_TEST_VAR=value1

BASHMENU_HOME=/opt/bashmenu

EOF
    
    run load_env_file "$TEST_ENV_FILE"
    [ "$status" -eq 0 ]
    [ "$BASHMENU_TEST_VAR" = "value1" ]
}

@test "load_env_file: removes quotes from values" {
    cat > "$TEST_ENV_FILE" << 'EOF'
BASHMENU_TEST_VAR="quoted_value"
BASHMENU_HOME='/opt/bashmenu'
EOF
    
    run load_env_file "$TEST_ENV_FILE"
    [ "$status" -eq 0 ]
    [ "$BASHMENU_TEST_VAR" = "quoted_value" ]
    [ "$BASHMENU_HOME" = "/opt/bashmenu" ]
}

@test "load_env_file: expands variables in values" {
    export BASHMENU_HOME="/opt/bashmenu"
    
    cat > "$TEST_ENV_FILE" << 'EOF'
BASHMENU_PLUGINS_DIR=${BASHMENU_HOME}/plugins
EOF
    
    run load_env_file "$TEST_ENV_FILE"
    [ "$status" -eq 0 ]
    [ "$BASHMENU_PLUGINS_DIR" = "/opt/bashmenu/plugins" ]
}

@test "load_env_file: does not override existing environment variables" {
    export BASHMENU_TEST_VAR="existing_value"
    
    cat > "$TEST_ENV_FILE" << 'EOF'
BASHMENU_TEST_VAR=new_value
EOF
    
    run load_env_file "$TEST_ENV_FILE"
    [ "$status" -eq 0 ]
    [ "$BASHMENU_TEST_VAR" = "existing_value" ]
}

@test "load_env_file: returns 1 for file with syntax errors" {
    cat > "$TEST_ENV_FILE" << 'EOF'
BASHMENU_TEST_VAR=value
if [ true ]; then
EOF
    
    run load_env_file "$TEST_ENV_FILE"
    [ "$status" -eq 1 ]
}

# =============================================================================
# Tests for get_config()
# =============================================================================

@test "get_config: returns environment variable value" {
    export BASHMENU_TEST_VAR="env_value"
    
    result=$(get_config "BASHMENU_TEST_VAR")
    [ "$result" = "env_value" ]
}

@test "get_config: returns default value when key not found" {
    result=$(get_config "BASHMENU_NONEXISTENT" "default_value")
    [ "$result" = "default_value" ]
}

@test "get_config: returns cached value" {
    BASHMENU_CONFIG_CACHE["BASHMENU_TEST_VAR"]="cached_value"
    
    result=$(get_config "BASHMENU_TEST_VAR")
    [ "$result" = "cached_value" ]
}

@test "get_config: returns default from BASHMENU_DEFAULTS" {
    result=$(get_config "BASHMENU_THEME")
    [ "$result" = "modern" ]
}

# =============================================================================
# Tests for set_config()
# =============================================================================

@test "set_config: sets configuration value" {
    run set_config "BASHMENU_TEST_VAR" "new_value"
    [ "$status" -eq 0 ]
    [ "$BASHMENU_TEST_VAR" = "new_value" ]
}

@test "set_config: updates cache" {
    set_config "BASHMENU_TEST_VAR" "cached_value"
    [ "${BASHMENU_CONFIG_CACHE[BASHMENU_TEST_VAR]}" = "cached_value" ]
}

# =============================================================================
# Tests for is_config_enabled()
# =============================================================================

@test "is_config_enabled: returns 0 for true value" {
    export BASHMENU_TEST_VAR="true"
    
    run is_config_enabled "BASHMENU_TEST_VAR"
    [ "$status" -eq 0 ]
}

@test "is_config_enabled: returns 1 for false value" {
    export BASHMENU_TEST_VAR="false"
    
    run is_config_enabled "BASHMENU_TEST_VAR"
    [ "$status" -eq 1 ]
}

@test "is_config_enabled: returns 1 for non-boolean value" {
    export BASHMENU_TEST_VAR="not_a_boolean"
    
    run is_config_enabled "BASHMENU_TEST_VAR"
    [ "$status" -eq 1 ]
}

@test "is_config_enabled: returns 1 when key not found" {
    run is_config_enabled "BASHMENU_NONEXISTENT"
    [ "$status" -eq 1 ]
}

# =============================================================================
# Tests for validate_config()
# =============================================================================

@test "validate_config: corrects invalid boolean values" {
    export BASHMENU_ENABLE_CACHE="invalid"
    
    run validate_config
    [ "$status" -eq 0 ]
    [ "$BASHMENU_ENABLE_CACHE" = "true" ]
}

@test "validate_config: corrects invalid log level" {
    export BASHMENU_LOG_LEVEL="INVALID"
    
    run validate_config
    [ "$status" -eq 0 ]
    [ "$BASHMENU_LOG_LEVEL" = "INFO" ]
}

@test "validate_config: accepts valid log levels" {
    export BASHMENU_LOG_LEVEL="DEBUG"
    
    run validate_config
    [ "$status" -eq 0 ]
    [ "$BASHMENU_LOG_LEVEL" = "DEBUG" ]
}

@test "validate_config: corrects invalid cache TTL" {
    export BASHMENU_CACHE_TTL="not_a_number"
    
    run validate_config
    [ "$status" -eq 0 ]
    [ "$BASHMENU_CACHE_TTL" = "3600" ]
}

@test "validate_config: corrects invalid theme" {
    export BASHMENU_THEME="invalid_theme"
    
    run validate_config
    [ "$status" -eq 0 ]
    [ "$BASHMENU_THEME" = "modern" ]
}

@test "validate_config: creates missing user directories" {
    export BASHMENU_USER_DIR="$TEST_DIR/user"
    export BASHMENU_PLUGINS_DIR="$TEST_DIR/plugins"
    export BASHMENU_CACHE_DIR="$TEST_DIR/cache"
    
    run validate_config
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/user" ]
    [ -d "$TEST_DIR/plugins" ]
    [ -d "$TEST_DIR/cache" ]
}

# =============================================================================
# Tests for load_configuration()
# =============================================================================

@test "load_configuration: loads defaults when no config file exists" {
    # Ensure no config files exist
    export HOME="$TEST_DIR/fake_home"
    mkdir -p "$HOME"
    
    run load_configuration
    [ "$status" -eq 0 ]
    [ "$BASHMENU_CONFIG_LOADED" = "true" ]
    [ "$BASHMENU_THEME" = "modern" ]
}

@test "load_configuration: sets BASHMENU_CONFIG_LOADED flag" {
    run load_configuration
    [ "$status" -eq 0 ]
    [ "$BASHMENU_CONFIG_LOADED" = "true" ]
}

@test "load_configuration: applies default values" {
    run load_configuration
    [ "$status" -eq 0 ]
    [ -n "$BASHMENU_HOME" ]
    [ -n "$BASHMENU_THEME" ]
    [ -n "$BASHMENU_LOG_LEVEL" ]
}
