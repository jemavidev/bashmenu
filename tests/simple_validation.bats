#!/usr/bin/env bats
# =============================================================================
# Simple BATS Test Suite for Bashmenu
# =============================================================================
# Description: Basic functionality tests without complex dependencies
# Version:     1.0
# =============================================================================

# Test basic validation functions
@test "input validation module loads" {
    run source ../src/input_validation.sh
    [ "$status" -eq 0 ]
}

@test "validate_alphanumeric function exists" {
    run bash -c "source ../src/input_validation.sh && declare -f validate_alphanumeric"
    [ "$status" -eq 0 ]
}

@test "validate_file_path function exists" {
    run bash -c "source ../src/input_validation.sh && declare -f validate_file_path"
    [ "$status" -eq 0 ]
}

@test "validate_script_name function exists" {
    run bash -c "source ../src/input_validation.sh && declare -f validate_script_name"
    [ "$status" -eq 0 ]
}

@test "sanitize_input function exists" {
    run bash -c "source ../src/input_validation.sh && declare -f sanitize_input"
    [ "$status" -eq 0 ]
}

@test "validate_positive_integer function exists" {
    run bash -c "source ../src/input_validation.sh && declare -f validate_positive_integer"
    [ "$status" -eq 0 ]
}

@test "validate_port function exists" {
    run bash -c "source ../src/input_validation.sh && declare -f validate_port"
    [ "$status" -eq 0 ]
}

@test "validate_ipv4 function exists" {
    run bash -c "source ../src/input_validation.sh && declare -f validate_ipv4"
    [ "$status" -eq 0 ]
}

@test "validate_url function exists" {
    run bash -c "source ../src/input_validation.sh && declare -f validate_url"
    [ "$status" -eq 0 ]
}

@test "validate_email function exists" {
    run bash -c "source ../src/input_validation.sh && declare -f validate_email"
    [ "$status" -eq 0 ]
}

@test "validate_alphanumeric with valid input" {
    run bash -c 'source ../src/input_validation.sh && validate_alphanumeric "test123"'
    [ "$status" -eq 0 ]
}

@test "validate_alphanumeric rejects invalid characters" {
    run bash -c 'source ../src/input_validation.sh && validate_alphanumeric "test@123"'
    [ "$status" -eq 1 ]
}

@test "validate_file_path rejects directory traversal" {
    run bash -c 'source ../src/input_validation.sh && validate_file_path "../../../etc/passwd"'
    [ "$status" -eq 1 ]
}

@test "validate_script_name with valid names" {
    run bash -c 'source ../src/input_validation.sh && validate_script_name "test_script_123"'
    [ "$status" -eq 0 ]
}

@test "validate_script_name rejects invalid starting characters" {
    run bash -c 'source ../src/input_validation.sh && validate_script_name "123script"'
    [ "$status" -eq 1 ]
}

@test "sanitize_input removes dangerous characters" {
    result=$(bash -c 'source ../src/input_validation.sh && sanitize_input "test; rm -rf /"')
    [[ ! "$result" =~ ";" ]]
}

@test "validate_positive_integer with valid numbers" {
    run bash -c 'source ../src/input_validation.sh && validate_positive_integer "123"'
    [ "$status" -eq 0 ]
}

@test "validate_positive_integer rejects negative numbers" {
    run bash -c 'source ../src/input_validation.sh && validate_positive_integer "-1"'
    [ "$status" -eq 1 ]
}

@test "validate_port with valid ports" {
    run bash -c 'source ../src/input_validation.sh && validate_port "80"'
    [ "$status" -eq 0 ]
}

@test "validate_port rejects invalid ports" {
    run bash -c 'source ../src/input_validation.sh && validate_port "65536"'
    [ "$status" -eq 1 ]
}

@test "validate_ipv4 with valid addresses" {
    run bash -c 'source ../src/input_validation.sh && validate_ipv4 "192.168.1.1"'
    [ "$status" -eq 0 ]
}

@test "validate_ipv4 rejects invalid addresses" {
    run bash -c 'source ../src/input_validation.sh && validate_ipv4 "256.1.1.1"'
    [ "$status" -eq 1 ]
}

@test "validate_url with valid URLs" {
    run bash -c 'source ../src/input_validation.sh && validate_url "https://example.com"'
    [ "$status" -eq 0 ]
}

@test "validate_url rejects invalid URLs" {
    run bash -c 'source ../src/input_validation.sh && validate_url "not-a-url"'
    [ "$status" -eq 1 ]
}

@test "validate_email with valid emails" {
    run bash -c 'source ../src/input_validation.sh && validate_email "test@example.com"'
    [ "$status" -eq 0 ]
}

@test "validate_email rejects invalid emails" {
    run bash -c 'source ../src/input_validation.sh && validate_email "invalid-email"'
    [ "$status" -eq 1 ]
}