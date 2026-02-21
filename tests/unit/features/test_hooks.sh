#!/usr/bin/env bash
# Tests for hooks.sh module

# Test hook functions
test_hook_success() {
    echo "Hook executed: test_hook_success"
    return 0
}

test_hook_fail() {
    echo "Hook executed: test_hook_fail"
    return 1
}

test_hook_priority_1() {
    echo "Priority 1"
    return 0
}

test_hook_priority_2() {
    echo "Priority 2"
    return 0
}

test_hook_priority_3() {
    echo "Priority 3"
    return 0
}

# Source the module
source "$(dirname "$0")/../../../src/features/hooks.sh"

# Test 1: hooks_init
test_hooks_init() {
    echo "Test 1: hooks_init"
    
    hooks_init
    
    if [[ "$HOOKS_ENABLED" == "true" ]] && [[ ${#HOOKS_REGISTRY[@]} -eq 0 ]]; then
        echo "✓ PASS: Hooks initialized"
        return 0
    else
        echo "✗ FAIL: Initialization failed"
        return 1
    fi
}

# Test 2: register_hook
test_register_hook() {
    echo "Test 2: register_hook"
    hooks_init
    
    register_hook "pre_execute" "test_hook_success" 50 > /dev/null
    
    if [[ -n "${HOOKS_REGISTRY[pre_execute:test_hook_success]}" ]]; then
        echo "✓ PASS: Hook registered"
        return 0
    else
        echo "✗ FAIL: Hook not registered"
        return 1
    fi
}

# Test 3: register_hook with invalid name
test_register_hook_invalid() {
    echo "Test 3: register_hook with invalid name"
    hooks_init
    
    if ! register_hook "invalid_hook" "test_hook_success" 50 2>/dev/null; then
        echo "✓ PASS: Invalid hook name rejected"
        return 0
    else
        echo "✗ FAIL: Invalid hook name accepted"
        return 1
    fi
}

# Test 4: unregister_hook
test_unregister_hook() {
    echo "Test 4: unregister_hook"
    hooks_init
    
    register_hook "pre_execute" "test_hook_success" 50 > /dev/null
    unregister_hook "pre_execute" "test_hook_success" > /dev/null
    
    if [[ -z "${HOOKS_REGISTRY[pre_execute:test_hook_success]}" ]]; then
        echo "✓ PASS: Hook unregistered"
        return 0
    else
        echo "✗ FAIL: Hook still registered"
        return 1
    fi
}

# Test 5: execute_hooks - success
test_execute_hooks_success() {
    echo "Test 5: execute_hooks - success"
    hooks_init
    
    register_hook "pre_execute" "test_hook_success" 50 > /dev/null
    
    if execute_hooks "pre_execute" > /dev/null; then
        echo "✓ PASS: Hooks executed successfully"
        return 0
    else
        echo "✗ FAIL: Hook execution failed"
        return 1
    fi
}

# Test 6: execute_hooks - failure (cancellation)
test_execute_hooks_cancel() {
    echo "Test 6: execute_hooks - failure (cancellation)"
    hooks_init
    
    register_hook "pre_execute" "test_hook_fail" 50 > /dev/null
    
    if ! execute_hooks "pre_execute" 2>/dev/null; then
        echo "✓ PASS: Hook cancellation works"
        return 0
    else
        echo "✗ FAIL: Hook should have cancelled"
        return 1
    fi
}

# Test 7: Priority ordering
test_hooks_priority() {
    echo "Test 7: Priority ordering"
    hooks_init
    
    register_hook "pre_execute" "test_hook_priority_3" 30 > /dev/null
    register_hook "pre_execute" "test_hook_priority_1" 10 > /dev/null
    register_hook "pre_execute" "test_hook_priority_2" 20 > /dev/null
    
    local output
    output=$(execute_hooks "pre_execute" 2>&1)
    
    # Check if priority 1 comes before priority 2 and 3
    if echo "$output" | grep -q "Priority 1.*Priority 2.*Priority 3"; then
        echo "✓ PASS: Priority ordering correct"
        return 0
    else
        echo "✗ FAIL: Priority ordering incorrect"
        echo "Output: $output"
        return 1
    fi
}

# Test 8: list_hooks
test_list_hooks() {
    echo "Test 8: list_hooks"
    hooks_init
    
    register_hook "pre_execute" "test_hook_success" 50 > /dev/null
    register_hook "post_execute" "test_hook_success" 50 > /dev/null
    
    local output
    output=$(list_hooks)
    
    if echo "$output" | grep -q "pre_execute" && echo "$output" | grep -q "post_execute"; then
        echo "✓ PASS: List hooks works"
        return 0
    else
        echo "✗ FAIL: List hooks failed"
        return 1
    fi
}

# Test 9: hooks_enable/disable
test_hooks_enable_disable() {
    echo "Test 9: hooks_enable/disable"
    hooks_init
    
    hooks_disable > /dev/null
    local disabled
    hooks_is_enabled && disabled=false || disabled=true
    
    hooks_enable > /dev/null
    local enabled
    hooks_is_enabled && enabled=true || enabled=false
    
    if [[ "$disabled" == "true" ]] && [[ "$enabled" == "true" ]]; then
        echo "✓ PASS: Enable/disable works"
        return 0
    else
        echo "✗ FAIL: Enable/disable failed"
        return 1
    fi
}

# Test 10: hooks_count
test_hooks_count() {
    echo "Test 10: hooks_count"
    hooks_init
    
    register_hook "pre_execute" "test_hook_success" 50 > /dev/null
    register_hook "pre_execute" "test_hook_fail" 50 > /dev/null
    register_hook "post_execute" "test_hook_success" 50 > /dev/null
    
    local total_count pre_count
    total_count=$(hooks_count)
    pre_count=$(hooks_count "pre_execute")
    
    if [[ $total_count -eq 3 ]] && [[ $pre_count -eq 2 ]]; then
        echo "✓ PASS: Hook counting works"
        return 0
    else
        echo "✗ FAIL: Hook counting failed (total: $total_count, pre: $pre_count)"
        return 1
    fi
}

# Test 11: hooks_clear
test_hooks_clear() {
    echo "Test 11: hooks_clear"
    hooks_init
    
    register_hook "pre_execute" "test_hook_success" 50 > /dev/null
    register_hook "post_execute" "test_hook_success" 50 > /dev/null
    
    hooks_clear > /dev/null
    
    local count
    count=$(hooks_count)
    
    if [[ $count -eq 0 ]]; then
        echo "✓ PASS: Clear works"
        return 0
    else
        echo "✗ FAIL: Clear failed (count: $count)"
        return 1
    fi
}

# Test 12: Multiple hooks same event
test_multiple_hooks() {
    echo "Test 12: Multiple hooks same event"
    hooks_init
    
    register_hook "pre_execute" "test_hook_priority_1" 10 > /dev/null
    register_hook "pre_execute" "test_hook_priority_2" 20 > /dev/null
    
    local output
    output=$(execute_hooks "pre_execute" 2>&1)
    
    if echo "$output" | grep -q "Priority 1" && echo "$output" | grep -q "Priority 2"; then
        echo "✓ PASS: Multiple hooks execute"
        return 0
    else
        echo "✗ FAIL: Multiple hooks failed"
        return 1
    fi
}

# Run all tests
main() {
    local passed=0
    local failed=0
    
    echo "================================"
    echo "Running Hooks Module Tests"
    echo "================================"
    echo ""
    
    test_hooks_init && ((passed++)) || ((failed++))
    test_register_hook && ((passed++)) || ((failed++))
    test_register_hook_invalid && ((passed++)) || ((failed++))
    test_unregister_hook && ((passed++)) || ((failed++))
    test_execute_hooks_success && ((passed++)) || ((failed++))
    test_execute_hooks_cancel && ((passed++)) || ((failed++))
    test_hooks_priority && ((passed++)) || ((failed++))
    test_list_hooks && ((passed++)) || ((failed++))
    test_hooks_enable_disable && ((passed++)) || ((failed++))
    test_hooks_count && ((passed++)) || ((failed++))
    test_hooks_clear && ((passed++)) || ((failed++))
    test_multiple_hooks && ((passed++)) || ((failed++))
    
    echo ""
    echo "================================"
    echo "Test Results"
    echo "================================"
    echo "Passed: $passed"
    echo "Failed: $failed"
    echo "Total:  $((passed + failed))"
    echo ""
    
    if [[ $failed -eq 0 ]]; then
        echo "✓ All tests passed!"
        return 0
    else
        echo "✗ Some tests failed"
        return 1
    fi
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
