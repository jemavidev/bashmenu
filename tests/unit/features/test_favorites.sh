#!/usr/bin/env bash
# Tests for favorites.sh module

# Setup test environment
setup_test_env() {
    export TEST_DIR="/tmp/bashmenu_favorites_test_$$"
    export BASHMENU_USER_DIR="$TEST_DIR/.bashmenu"
    export FAVORITES_FILE="$BASHMENU_USER_DIR/favorites.json"
    
    mkdir -p "$TEST_DIR/scripts"
    mkdir -p "$BASHMENU_USER_DIR"
    
    # Create test scripts
    echo "#!/bin/bash" > "$TEST_DIR/scripts/script1.sh"
    echo "#!/bin/bash" > "$TEST_DIR/scripts/script2.sh"
    echo "#!/bin/bash" > "$TEST_DIR/scripts/script3.sh"
    
    chmod +x "$TEST_DIR/scripts"/*.sh
}

# Cleanup test environment
cleanup_test_env() {
    rm -rf "$TEST_DIR"
}

# Source the module
source "$(dirname "$0")/../../../src/features/favorites.sh"

# Test 1: favorites_init
test_favorites_init() {
    echo "Test 1: favorites_init"
    setup_test_env
    
    favorites_init
    
    if [[ -f "$FAVORITES_FILE" ]]; then
        echo "✓ PASS: Favorites file created"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Favorites file not created"
        cleanup_test_env
        return 1
    fi
}

# Test 2: favorites_add
test_favorites_add() {
    echo "Test 2: favorites_add"
    setup_test_env
    favorites_init
    
    favorites_add "$TEST_DIR/scripts/script1.sh" > /dev/null
    
    if [[ -n "${FAVORITES_MAP[$TEST_DIR/scripts/script1.sh]}" ]]; then
        echo "✓ PASS: Script added to favorites"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Script not added"
        cleanup_test_env
        return 1
    fi
}

# Test 3: favorites_remove
test_favorites_remove() {
    echo "Test 3: favorites_remove"
    setup_test_env
    favorites_init
    
    favorites_add "$TEST_DIR/scripts/script1.sh" > /dev/null
    favorites_remove "$TEST_DIR/scripts/script1.sh" > /dev/null
    
    if [[ -z "${FAVORITES_MAP[$TEST_DIR/scripts/script1.sh]}" ]]; then
        echo "✓ PASS: Script removed from favorites"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Script not removed"
        cleanup_test_env
        return 1
    fi
}

# Test 4: favorites_is_favorite
test_favorites_is_favorite() {
    echo "Test 4: favorites_is_favorite"
    setup_test_env
    favorites_init
    
    favorites_add "$TEST_DIR/scripts/script1.sh" > /dev/null
    
    if favorites_is_favorite "$TEST_DIR/scripts/script1.sh"; then
        echo "✓ PASS: Correctly identifies favorite"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Failed to identify favorite"
        cleanup_test_env
        return 1
    fi
}

# Test 5: favorites_list
test_favorites_list() {
    echo "Test 5: favorites_list"
    setup_test_env
    favorites_init
    
    favorites_add "$TEST_DIR/scripts/script1.sh" > /dev/null
    favorites_add "$TEST_DIR/scripts/script2.sh" > /dev/null
    
    local count
    count=$(favorites_list | wc -l)
    
    if [[ $count -eq 2 ]]; then
        echo "✓ PASS: Lists all favorites"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: List count incorrect (expected 2, got $count)"
        cleanup_test_env
        return 1
    fi
}

# Test 6: favorites_toggle
test_favorites_toggle() {
    echo "Test 6: favorites_toggle"
    setup_test_env
    favorites_init
    
    # Toggle on
    favorites_toggle "$TEST_DIR/scripts/script1.sh" > /dev/null
    local is_fav1
    favorites_is_favorite "$TEST_DIR/scripts/script1.sh" && is_fav1=true || is_fav1=false
    
    # Toggle off
    favorites_toggle "$TEST_DIR/scripts/script1.sh" > /dev/null
    local is_fav2
    favorites_is_favorite "$TEST_DIR/scripts/script1.sh" && is_fav2=true || is_fav2=false
    
    if [[ "$is_fav1" == "true" ]] && [[ "$is_fav2" == "false" ]]; then
        echo "✓ PASS: Toggle works correctly"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Toggle failed"
        cleanup_test_env
        return 1
    fi
}

# Test 7: favorites_save and favorites_load
test_favorites_persistence() {
    echo "Test 7: favorites_save and favorites_load"
    setup_test_env
    favorites_init
    
    # Add favorites
    favorites_add "$TEST_DIR/scripts/script1.sh" > /dev/null
    favorites_add "$TEST_DIR/scripts/script2.sh" > /dev/null
    
    # Clear memory and reload
    FAVORITES_MAP=()
    favorites_load
    
    local count="${#FAVORITES_MAP[@]}"
    
    if [[ $count -eq 2 ]]; then
        echo "✓ PASS: Favorites persist across load"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Persistence failed (expected 2, got $count)"
        cleanup_test_env
        return 1
    fi
}

# Test 8: favorites_count
test_favorites_count() {
    echo "Test 8: favorites_count"
    setup_test_env
    favorites_init
    
    favorites_add "$TEST_DIR/scripts/script1.sh" > /dev/null
    favorites_add "$TEST_DIR/scripts/script2.sh" > /dev/null
    favorites_add "$TEST_DIR/scripts/script3.sh" > /dev/null
    
    local count
    count=$(favorites_count)
    
    if [[ $count -eq 3 ]]; then
        echo "✓ PASS: Count is correct"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Count incorrect (expected 3, got $count)"
        cleanup_test_env
        return 1
    fi
}

# Test 9: favorites_export
test_favorites_export() {
    echo "Test 9: favorites_export"
    setup_test_env
    favorites_init
    
    favorites_add "$TEST_DIR/scripts/script1.sh" > /dev/null
    
    local export_file="$TEST_DIR/export.json"
    favorites_export "$export_file" > /dev/null
    
    if [[ -f "$export_file" ]]; then
        echo "✓ PASS: Export successful"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Export failed"
        cleanup_test_env
        return 1
    fi
}

# Test 10: favorites_import (merge mode)
test_favorites_import_merge() {
    echo "Test 10: favorites_import (merge mode)"
    setup_test_env
    favorites_init
    
    # Add one favorite
    favorites_add "$TEST_DIR/scripts/script1.sh" > /dev/null
    
    # Create import file with different favorite
    cat > "$TEST_DIR/import.json" << EOF
{
  "version": "1.0",
  "favorites": [
    {
      "script": "$TEST_DIR/scripts/script2.sh",
      "name": "script2",
      "added": "2026-02-20T00:00:00Z"
    }
  ]
}
EOF
    
    favorites_import "$TEST_DIR/import.json" "merge" > /dev/null
    
    local count
    count=$(favorites_count)
    
    if [[ $count -eq 2 ]]; then
        echo "✓ PASS: Import merge works"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Import merge failed (expected 2, got $count)"
        cleanup_test_env
        return 1
    fi
}

# Test 11: favorites_clear
test_favorites_clear() {
    echo "Test 11: favorites_clear"
    setup_test_env
    favorites_init
    
    favorites_add "$TEST_DIR/scripts/script1.sh" > /dev/null
    favorites_add "$TEST_DIR/scripts/script2.sh" > /dev/null
    
    favorites_clear > /dev/null
    
    local count
    count=$(favorites_count)
    
    if [[ $count -eq 0 ]]; then
        echo "✓ PASS: Clear works"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Clear failed (expected 0, got $count)"
        cleanup_test_env
        return 1
    fi
}

# Test 12: favorites_indicator
test_favorites_indicator() {
    echo "Test 12: favorites_indicator"
    setup_test_env
    favorites_init
    
    favorites_add "$TEST_DIR/scripts/script1.sh" > /dev/null
    
    local indicator
    indicator=$(favorites_indicator "$TEST_DIR/scripts/script1.sh")
    
    if [[ "$indicator" == "⭐" ]]; then
        echo "✓ PASS: Indicator shows star for favorite"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Indicator incorrect"
        cleanup_test_env
        return 1
    fi
}

# Run all tests
main() {
    local passed=0
    local failed=0
    
    echo "================================"
    echo "Running Favorites Module Tests"
    echo "================================"
    echo ""
    
    test_favorites_init && ((passed++)) || ((failed++))
    test_favorites_add && ((passed++)) || ((failed++))
    test_favorites_remove && ((passed++)) || ((failed++))
    test_favorites_is_favorite && ((passed++)) || ((failed++))
    test_favorites_list && ((passed++)) || ((failed++))
    test_favorites_toggle && ((passed++)) || ((failed++))
    test_favorites_persistence && ((passed++)) || ((failed++))
    test_favorites_count && ((passed++)) || ((failed++))
    test_favorites_export && ((passed++)) || ((failed++))
    test_favorites_import_merge && ((passed++)) || ((failed++))
    test_favorites_clear && ((passed++)) || ((failed++))
    test_favorites_indicator && ((passed++)) || ((failed++))
    
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
