#!/usr/bin/env bash
# Tests for audit.sh module

# Setup
setup_test_env() {
    export TEST_DIR="/tmp/bashmenu_audit_test_$$"
    export BASHMENU_USER_DIR="$TEST_DIR/.bashmenu"
    export AUDIT_FILE="$BASHMENU_USER_DIR/audit.jsonl"
    
    mkdir -p "$BASHMENU_USER_DIR"
}

cleanup_test_env() {
    rm -rf "$TEST_DIR"
}

# Source module
source "$(dirname "$0")/../../../src/features/audit.sh"

# Test 1: audit_init
test_audit_init() {
    echo "Test 1: audit_init"
    setup_test_env
    
    audit_init
    
    if [[ -f "$AUDIT_FILE" ]]; then
        echo "✓ PASS: Audit file created"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Audit file not created"
        cleanup_test_env
        return 1
    fi
}

# Test 2: audit_log_event
test_audit_log_event() {
    echo "Test 2: audit_log_event"
    setup_test_env
    audit_init
    
    audit_log_event "execute_script" "/test/script.sh" "success" 0 100
    
    if [[ -s "$AUDIT_FILE" ]]; then
        echo "✓ PASS: Event logged"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Event not logged"
        cleanup_test_env
        return 1
    fi
}

# Test 3: audit_query
test_audit_query() {
    echo "Test 3: audit_query"
    setup_test_env
    audit_init
    
    audit_log_event "execute_script" "/test/script1.sh" "success" 0 100
    audit_log_event "search" "" "success" 0 50
    audit_log_event "execute_script" "/test/script2.sh" "failure" 1 200
    
    local results
    results=$(audit_query "action" "execute_script")
    local count
    count=$(echo "$results" | wc -l | tr -d ' ')
    
    cleanup_test_env
    
    if [[ $count -eq 2 ]]; then
        echo "✓ PASS: Query works (found $count)"
        return 0
    else
        echo "✗ FAIL: Query failed (expected 2, got $count)"
        return 1
    fi
}

# Test 4: audit_stats
test_audit_stats() {
    echo "Test 4: audit_stats"
    setup_test_env
    audit_init
    
    audit_log_event "test1" "" "success" 0 10
    audit_log_event "test2" "" "success" 0 20
    audit_log_event "test3" "" "failure" 1 30
    
    local stats
    stats=$(audit_stats)
    
    cleanup_test_env
    
    if echo "$stats" | grep -q '"total_events": 3'; then
        echo "✓ PASS: Stats correct"
        return 0
    else
        echo "✗ FAIL: Stats incorrect"
        return 1
    fi
}

# Test 5: audit_export JSONL
test_audit_export_jsonl() {
    echo "Test 5: audit_export JSONL"
    setup_test_env
    audit_init
    
    audit_log_event "test" "" "success" 0 10
    
    local export_file="$TEST_DIR/export.jsonl"
    audit_export "$export_file" "jsonl" > /dev/null
    
    cleanup_test_env
    
    if [[ -f "$export_file" ]]; then
        echo "✓ PASS: JSONL export works"
        return 0
    else
        echo "✗ FAIL: Export failed"
        return 1
    fi
}

# Test 6: audit_export CSV
test_audit_export_csv() {
    echo "Test 6: audit_export CSV"
    setup_test_env
    audit_init
    
    audit_log_event "test" "/script.sh" "success" 0 10
    
    local export_file="$TEST_DIR/export.csv"
    audit_export "$export_file" "csv" > /dev/null
    
    local has_header
    has_header=$(head -n1 "$export_file" | grep -c "timestamp,user,action")
    
    cleanup_test_env
    
    if [[ $has_header -eq 1 ]]; then
        echo "✓ PASS: CSV export works"
        return 0
    else
        echo "✗ FAIL: CSV export failed"
        return 1
    fi
}

# Test 7: audit_clear
test_audit_clear() {
    echo "Test 7: audit_clear"
    setup_test_env
    audit_init
    
    audit_log_event "test" "" "success" 0 10
    audit_clear > /dev/null
    
    local size
    size=$(stat -f%z "$AUDIT_FILE" 2>/dev/null || stat -c%s "$AUDIT_FILE" 2>/dev/null || echo 0)
    
    cleanup_test_env
    
    if [[ $size -eq 0 ]]; then
        echo "✓ PASS: Clear works"
        return 0
    else
        echo "✗ FAIL: Clear failed"
        return 1
    fi
}

# Test 8: audit_enable/disable
test_audit_enable_disable() {
    echo "Test 8: audit_enable/disable"
    setup_test_env
    audit_init
    
    audit_disable > /dev/null
    audit_log_event "test1" "" "success" 0 10
    
    audit_enable > /dev/null
    audit_log_event "test2" "" "success" 0 10
    
    local count
    count=$(wc -l < "$AUDIT_FILE" | tr -d ' ')
    
    cleanup_test_env
    
    if [[ $count -eq 1 ]]; then
        echo "✓ PASS: Enable/disable works"
        return 0
    else
        echo "✗ FAIL: Enable/disable failed (count: $count)"
        return 1
    fi
}

# Run all tests
main() {
    local passed=0
    local failed=0
    
    echo "================================"
    echo "Running Audit Module Tests"
    echo "================================"
    echo ""
    
    test_audit_init && ((passed++)) || ((failed++))
    test_audit_log_event && ((passed++)) || ((failed++))
    test_audit_query && ((passed++)) || ((failed++))
    test_audit_stats && ((passed++)) || ((failed++))
    test_audit_export_jsonl && ((passed++)) || ((failed++))
    test_audit_export_csv && ((passed++)) || ((failed++))
    test_audit_clear && ((passed++)) || ((failed++))
    test_audit_enable_disable && ((passed++)) || ((failed++))
    
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

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
