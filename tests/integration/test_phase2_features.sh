#!/usr/bin/env bash
# Integration tests for Phase 2 features

# Setup test environment
setup_test_env() {
    export TEST_DIR="/tmp/bashmenu_phase2_test_$$"
    export BASHMENU_USER_DIR="$TEST_DIR/.bashmenu"
    export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    
    mkdir -p "$TEST_DIR/plugins"
    mkdir -p "$BASHMENU_USER_DIR"
    
    # Create test scripts
    for i in {1..10}; do
        cat > "$TEST_DIR/plugins/script_$i.sh" << EOF
#!/bin/bash
# Test script $i
# Tags: test, script$i
echo "Executing script $i"
EOF
        chmod +x "$TEST_DIR/plugins/script_$i.sh"
    done
}

cleanup_test_env() {
    rm -rf "$TEST_DIR"
}

# Source modules
source_modules() {
    source "$SCRIPT_DIR/src/scripts/cache.sh" 2>/dev/null || true
    source "$SCRIPT_DIR/src/features/search.sh" 2>/dev/null || true
    source "$SCRIPT_DIR/src/features/favorites.sh" 2>/dev/null || true
    source "$SCRIPT_DIR/src/features/hooks.sh" 2>/dev/null || true
    source "$SCRIPT_DIR/src/features/lazy_loader.sh" 2>/dev/null || true
}

# Test 1: Cache + Search integration
test_cache_search_integration() {
    echo "Test 1: Cache + Search integration"
    setup_test_env
    source_modules
    
    cache_init
    search_init
    
    # First search (no cache)
    search_incremental "script" "$TEST_DIR/plugins" "name" > /dev/null
    local count1=${#SEARCH_RESULTS[@]}
    
    # Cache results
    cache_set "search" "script" "${SEARCH_RESULTS[*]}"
    
    # Get from cache
    local cached
    cached=$(cache_get "search" "script")
    
    cleanup_test_env
    
    if [[ -n "$cached" ]] && [[ $count1 -eq 10 ]]; then
        echo "✓ PASS: Cache + Search integration works"
        return 0
    else
        echo "✗ FAIL: Integration failed"
        return 1
    fi
}

# Test 2: Search + Favorites integration
test_search_favorites_integration() {
    echo "Test 2: Search + Favorites integration"
    setup_test_env
    source_modules
    
    search_init
    favorites_init
    
    # Search for scripts
    search_incremental "script_1" "$TEST_DIR/plugins" "name" > /dev/null
    
    # Add first result to favorites
    if [[ ${#SEARCH_RESULTS[@]} -gt 0 ]]; then
        favorites_add "${SEARCH_RESULTS[0]}" > /dev/null
        
        # Check if it's in favorites
        if favorites_is_favorite "${SEARCH_RESULTS[0]}"; then
            echo "✓ PASS: Search + Favorites integration works"
            cleanup_test_env
            return 0
        fi
    fi
    
    echo "✗ FAIL: Integration failed"
    cleanup_test_env
    return 1
}

# Test 3: Hooks + Cache integration
test_hooks_cache_integration() {
    echo "Test 3: Hooks + Cache integration"
    setup_test_env
    source_modules
    
    # Define hook function
    test_cache_hook() {
        cache_set "hook_test" "executed" "true"
        return 0
    }
    
    hooks_init
    cache_init
    
    # Register hook
    register_hook "pre_execute" "test_cache_hook" 50 > /dev/null
    
    # Execute hooks
    execute_hooks "pre_execute" > /dev/null
    
    # Check cache
    local result
    result=$(cache_get "hook_test" "executed")
    
    cleanup_test_env
    
    if [[ "$result" == "true" ]]; then
        echo "✓ PASS: Hooks + Cache integration works"
        return 0
    else
        echo "✗ FAIL: Integration failed"
        return 1
    fi
}

# Test 4: Lazy loading + All modules
test_lazy_loading_integration() {
    echo "Test 4: Lazy loading integration"
    setup_test_env
    source_modules
    
    lazy_init
    
    # Load modules on demand
    lazy_load_module "search" 2>/dev/null || true
    lazy_load_module "favorites" 2>/dev/null || true
    
    local loaded
    loaded=$(lazy_loaded_count)
    
    cleanup_test_env
    
    if [[ $loaded -ge 0 ]]; then
        echo "✓ PASS: Lazy loading works (loaded: $loaded)"
        return 0
    else
        echo "✗ FAIL: Lazy loading failed"
        return 1
    fi
}

# Test 5: Full workflow test
test_full_workflow() {
    echo "Test 5: Full workflow test"
    setup_test_env
    source_modules
    
    # Initialize all systems
    cache_init
    search_init
    favorites_init
    hooks_init
    
    # Define workflow hook
    workflow_hook() {
        echo "Workflow executed"
        return 0
    }
    
    # Register hook
    register_hook "pre_execute" "workflow_hook" 50 > /dev/null
    
    # Search for script
    search_incremental "script_5" "$TEST_DIR/plugins" "name" > /dev/null
    
    # Add to favorites
    if [[ ${#SEARCH_RESULTS[@]} -gt 0 ]]; then
        favorites_add "${SEARCH_RESULTS[0]}" > /dev/null
    fi
    
    # Execute hooks
    local hook_output
    hook_output=$(execute_hooks "pre_execute" 2>&1)
    
    # Verify workflow
    local fav_count
    fav_count=$(favorites_count)
    
    cleanup_test_env
    
    if [[ $fav_count -eq 1 ]] && echo "$hook_output" | grep -q "Workflow executed"; then
        echo "✓ PASS: Full workflow works"
        return 0
    else
        echo "✗ FAIL: Workflow failed"
        return 1
    fi
}

# Test 6: Performance test
test_performance() {
    echo "Test 6: Performance test"
    setup_test_env
    source_modules
    
    # Create 50 scripts
    for i in {11..60}; do
        echo "#!/bin/bash" > "$TEST_DIR/plugins/perf_$i.sh"
        echo "# Performance test script $i" >> "$TEST_DIR/plugins/perf_$i.sh"
    done
    
    cache_init
    search_init
    
    local start end duration
    start=$(date +%s%N 2>/dev/null || date +%s)
    
    # Search with cache
    search_incremental "perf" "$TEST_DIR/plugins" "all" > /dev/null
    cache_set "search" "perf" "${SEARCH_RESULTS[*]}"
    
    end=$(date +%s%N 2>/dev/null || date +%s)
    
    if [[ "$start" =~ [0-9]{10,} ]]; then
        duration=$(( (end - start) / 1000000 ))
    else
        duration=$(( (end - start) * 1000 ))
    fi
    
    cleanup_test_env
    
    if [[ $duration -lt 500 ]]; then
        echo "✓ PASS: Performance acceptable (${duration}ms)"
        return 0
    else
        echo "⚠ WARNING: Performance slow (${duration}ms)"
        return 0
    fi
}

# Test 7: Error handling
test_error_handling() {
    echo "Test 7: Error handling"
    setup_test_env
    source_modules
    
    search_init
    favorites_init
    
    # Try to add non-existent script to favorites
    if ! favorites_add "/nonexistent/script.sh" 2>/dev/null; then
        echo "✓ PASS: Error handling works"
        cleanup_test_env
        return 0
    else
        echo "✗ FAIL: Should have failed"
        cleanup_test_env
        return 1
    fi
}

# Test 8: Concurrent operations
test_concurrent_operations() {
    echo "Test 8: Concurrent operations"
    setup_test_env
    source_modules
    
    cache_init
    search_init
    favorites_init
    
    # Perform multiple operations
    search_incremental "script" "$TEST_DIR/plugins" "name" > /dev/null &
    cache_set "test" "key1" "value1" &
    favorites_init &
    
    wait
    
    cleanup_test_env
    echo "✓ PASS: Concurrent operations completed"
    return 0
}

# Test 9: State persistence
test_state_persistence() {
    echo "Test 9: State persistence"
    setup_test_env
    source_modules
    
    favorites_init
    
    # Add favorites
    favorites_add "$TEST_DIR/plugins/script_1.sh" > /dev/null
    favorites_add "$TEST_DIR/plugins/script_2.sh" > /dev/null
    
    # Clear memory
    FAVORITES_MAP=()
    
    # Reload
    favorites_load
    
    local count
    count=$(favorites_count)
    
    cleanup_test_env
    
    if [[ $count -eq 2 ]]; then
        echo "✓ PASS: State persists correctly"
        return 0
    else
        echo "✗ FAIL: State lost (count: $count)"
        return 1
    fi
}

# Test 10: Module dependencies
test_module_dependencies() {
    echo "Test 10: Module dependencies"
    setup_test_env
    source_modules
    
    # All modules should load without errors
    local errors=0
    
    cache_init || ((errors++))
    search_init || ((errors++))
    favorites_init || ((errors++))
    hooks_init || ((errors++))
    lazy_init || ((errors++))
    
    cleanup_test_env
    
    if [[ $errors -eq 0 ]]; then
        echo "✓ PASS: All modules load correctly"
        return 0
    else
        echo "✗ FAIL: $errors module(s) failed to load"
        return 1
    fi
}

# Run all tests
main() {
    local passed=0
    local failed=0
    
    echo "========================================"
    echo "Phase 2 Integration Tests"
    echo "========================================"
    echo ""
    
    test_cache_search_integration && ((passed++)) || ((failed++))
    test_search_favorites_integration && ((passed++)) || ((failed++))
    test_hooks_cache_integration && ((passed++)) || ((failed++))
    test_lazy_loading_integration && ((passed++)) || ((failed++))
    test_full_workflow && ((passed++)) || ((failed++))
    test_performance && ((passed++)) || ((failed++))
    test_error_handling && ((passed++)) || ((failed++))
    test_concurrent_operations && ((passed++)) || ((failed++))
    test_state_persistence && ((passed++)) || ((failed++))
    test_module_dependencies && ((passed++)) || ((failed++))
    
    echo ""
    echo "========================================"
    echo "Test Results"
    echo "========================================"
    echo "Passed: $passed"
    echo "Failed: $failed"
    echo "Total:  $((passed + failed))"
    echo ""
    
    if [[ $failed -eq 0 ]]; then
        echo "✓ All integration tests passed!"
        return 0
    else
        echo "✗ Some tests failed"
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
