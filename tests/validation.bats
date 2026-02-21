#!/usr/bin/env bats
# =============================================================================
# BATS Test Suite for Bashmenu
# =============================================================================
# Description: Core functionality tests
# Version:     1.0
# =============================================================================

# Source only validation functions directly
source ../src/input_validation.sh

# Load menu functions selectively (avoid loading entire script)
source <(grep -A 50 "sanitize_script_path" ../src/menu.sh | grep -B 5 -A 20 "function sanitize_script_path\|sanitize_script_path()")

@test "validate_alphanumeric with valid input" {
    run validate_alphanumeric "test123"
    [ "$status" -eq 0 ]
}

@test "validate_alphanumeric with invalid characters" {
    run validate_alphanumeric "test@123"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "can only contain letters" ]]
}

@test "validate_alphanumeric with empty input" {
    run validate_alphanumeric ""
    [ "$status" -eq 1 ]
    [[ "$output" =~ "cannot be empty" ]]
}

@test "sanitize_script_path removes dangerous patterns" {
    local result=$(sanitize_script_path "../../../etc/passwd")
    [ "$result" = "" ] || [ "$result" != "../../../etc/passwd" ]
}

@test "sanitize_script_path handles safe paths" {
    local result=$(sanitize_script_path "plugins/test/script.sh")
    [ "$result" = "plugins/test/script.sh" ]
}

@test "validate_file_path rejects directory traversal" {
    run validate_file_path "../../../etc/passwd"
    [ "$status" -eq 1 ]
}

@test "validate_file_path accepts safe relative paths" {
    run validate_file_path "plugins/test/script.sh"
    [ "$status" -eq 0 ]
}

@test "validate_positive_integer with valid numbers" {
    run validate_positive_integer "123"
    [ "$status" -eq 0 ]
    
    run validate_positive_integer "0"
    [ "$status" -eq 0 ]
}

@test "validate_positive_integer with negative numbers" {
    run validate_positive_integer "-1"
    [ "$status" -eq 1 ]
}

@test "validate_positive_integer with non-numeric input" {
    run validate_positive_integer "abc"
    [ "$status" -eq 1 ]
}

@test "validate_script_name with valid names" {
    run validate_script_name "test_script_123"
    [ "$status" -eq 0 ]
}

@test "validate_script_name rejects invalid starting characters" {
    run validate_script_name "123script"
    [ "$status" -eq 1 ]
}

@test "validate_script_name rejects special characters" {
    run validate_script_name "test@script"
    [ "$status" -eq 1 ]
}

@test "sanitize_input removes dangerous characters" {
    local result=$(sanitize_input "test; rm -rf /")
    [[ "$result" != "test; rm -rf /" ]]
    [[ ! "$result" =~ ";" ]]
}

@test "sanitize_input preserves safe characters" {
    local result=$(sanitize_input "test-script_123")
    [ "$result" = "test-script_123" ]
}

@test "validate_port with valid ports" {
    run validate_port "80"
    [ "$status" -eq 0 ]
    
    run validate_port "443"
    [ "$status" -eq 0 ]
    
    run validate_port "65535"
    [ "$status" -eq 0 ]
}

@test "validate_port with invalid ports" {
    run validate_port "0"
    [ "$status" -eq 1 ]
    
    run validate_port "65536"
    [ "$status" -eq 1 ]
}

@test "validate_port with non-numeric input" {
    run validate_port "abc"
    [ "$status" -eq 1 ]
}

@test "validate_ipv4 with valid addresses" {
    run validate_ipv4 "192.168.1.1"
    [ "$status" -eq 0 ]
    
    run validate_ipv4 "127.0.0.1"
    [ "$status" -eq 0 ]
    
    run validate_ipv4 "255.255.255.255"
    [ "$status" -eq 0 ]
}

@test "validate_ipv4 with invalid addresses" {
    run validate_ipv4 "256.1.1.1"
    [ "$status" -eq 1 ]
    
    run validate_ipv4 "192.168.1"
    [ "$status" -eq 1 ]
    
    run validate_ipv4 "invalid.ip.address"
    [ "$status" -eq 1 ]
}

@test "validate_url with valid URLs" {
    run validate_url "https://example.com"
    [ "$status" -eq 0 ]
    
    run validate_url "http://test.example.com/path"
    [ "$status" -eq 0 ]
}

@test "validate_url with invalid URLs" {
    run validate_url "not-a-url"
    [ "$status" -eq 1 ]
    
    run validate_url "ftp://example.com"
    [ "$status" -eq 1 ]
}

@test "validate_email with valid emails" {
    run validate_email "test@example.com"
    [ "$status" -eq 0 ]
    
    run validate_email "user.name+tag@example.co.uk"
    [ "$status" -eq 0 ]
}

@test "validate_email with invalid emails" {
    run validate_email "invalid-email"
    [ "$status" -eq 1 ]
    
    run validate_email "@example.com"
    [ "$status" -eq 1 ]
}